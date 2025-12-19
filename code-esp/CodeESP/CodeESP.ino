#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <DHT.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// ------------------- WiFi -------------------
#define WIFI_SSID     "NHAT KHAI _tang3"
#define WIFI_PASSWORD "nhatkhai95"

// ------------------- Firebase -------------------
#define API_KEY       "AIzaSyBOeUq0N43luwhay7yyOdgYkr_yJ8QB_Is"
#define DATABASE_URL  "https://dulieumoitruong-e3085-default-rtdb.asia-southeast1.firebasedatabase.app"

// ✅ TÀI KHOẢN DEVICE (TẠO TRONG FIREBASE AUTH -> EMAIL/PASSWORD)
#define DEVICE_EMAIL    "thuanhuynhhp10@gmail.com"
#define DEVICE_PASSWORD "123456"

// ------------------- RTDB Base Path -------------------
static const char* BASE_PATH = "ESP32C3";

// ------------------- DHT -------------------
#define DHTPIN  3
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

// ------------------- MQ135 -------------------
#define MQ135_PIN 2

// ------------------- Dust GP2Y1010AU0F -------------------
const int dustPin   = 0;   // GPIO0 ADC
const int ledPower  = 1;   // GPIO1 LED control

const int delayTime  = 280;
const int delayTime2 = 40;
const int offTime    = 9680;

int   dustVal = 0;
float voltage = 0;
float dustDensity = 0;

// ------------------- Firebase -------------------
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// helper build "ESP32C3/xxx"
static inline String pathJoin(const char* key) {
  return String(BASE_PATH) + "/" + key;
}

void connectWiFi() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println("\n✅ WiFi Connected!");
  Serial.print("IP: ");
  Serial.println(WiFi.localIP());
}

void setupFirebase() {
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  // ✅ Login Email/Password (không dùng Anonymous)
  auth.user.email = DEVICE_EMAIL;
  auth.user.password = DEVICE_PASSWORD;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Serial.println("✅ Firebase login by Email/Password (device account)");
}

void setup() {
  Serial.begin(115200);
  delay(1000);

  connectWiFi();

  dht.begin();

  pinMode(ledPower, OUTPUT);
  digitalWrite(ledPower, HIGH); // LED tắt mặc định

  setupFirebase();

  Serial.println("ESP32-C3 GP2Y1010AU0F ready");
}

void loop() {
  // ----- DHT11 -----
  float h = dht.readHumidity();
  float t = dht.readTemperature();

  // ----- MQ135 -----
  int mq135Raw = analogRead(MQ135_PIN);

  // ----- Dust GP2Y1010AU0F -----
  digitalWrite(ledPower, LOW);
  delayMicroseconds(delayTime);
  dustVal = analogRead(dustPin);
  delayMicroseconds(delayTime2);
  digitalWrite(ledPower, HIGH);
  delayMicroseconds(offTime);

  voltage = dustVal * (3.3f / 4095.0f);
  dustDensity = 0.172f * voltage - 0.1f;
  if (dustDensity < 0) dustDensity = 0;
  if (dustDensity > 0.5f) dustDensity = 0.5f;

  float dustUg = dustDensity * 1000.0f;

  Serial.printf("T=%.1f°C H=%.1f%% MQ135=%d | Dust: %.3fV %.2f ug/m3\n",
                t, h, mq135Raw, voltage, dustUg);

  if (Firebase.ready()) {
    unsigned long lastSeen = millis();
    if (!Firebase.RTDB.setInt(&fbdo, pathJoin("last_seen").c_str(), (int)lastSeen)) {
      Serial.println(fbdo.errorReason());
    }

    // DHT
    if (!isnan(t) && !isnan(h)) {
      if (!Firebase.RTDB.setFloat(&fbdo, pathJoin("nhiet_do").c_str(), t))
        Serial.println(fbdo.errorReason());

      if (!Firebase.RTDB.setFloat(&fbdo, pathJoin("do_am").c_str(), h))
        Serial.println(fbdo.errorReason());
    } else {
      Serial.println("DHT read failed, skipping Firebase update");
    }

    // Dust
    if (!isnan(voltage) && !isnan(dustUg)) {
      if (!Firebase.RTDB.setFloat(&fbdo, pathJoin("dust_voltage").c_str(), voltage))
        Serial.println(fbdo.errorReason());

      if (!Firebase.RTDB.setFloat(&fbdo, pathJoin("dust_density").c_str(), dustUg))
        Serial.println(fbdo.errorReason());
    }

    // MQ135
    if (!Firebase.RTDB.setInt(&fbdo, pathJoin("mq135_raw").c_str(), mq135Raw))
      Serial.println(fbdo.errorReason());
  }

  delay(3000);
}
