#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <DHT.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// ------------------- WiFi -------------------
#define WIFI_SSID "NHAT KHAI _tang3"
#define WIFI_PASSWORD "nhatkhai95"

// ------------------- Firebase -------------------
#define API_KEY "AIzaSyBOeUq0N43luwhay7yyOdgYkr_yJ8QB_Is"
#define DATABASE_URL "https://dulieumoitruong-e3085-default-rtdb.asia-southeast1.firebasedatabase.app"

// ------------------- DHT -------------------
#define DHTPIN 3
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

// ------------------- MQ135 -------------------
#define MQ135_PIN 2

// ------------------- Dust GP2Y1010AU0F -------------------
const int dustPin = 0;    // GPIO0 ADC
const int ledPower = 1;   // GPIO1
const int delayTime = 280;    // microseconds
const int delayTime2 = 40;    // microseconds
const int offTime = 9680;     // microseconds

int dustVal = 0;
char s[32];
float voltage = 0;
float dustDensity = 0;

// ------------------- Firebase -------------------
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

void setup() {
  Serial.begin(115200);
  delay(1000);

  // --- WiFi ---
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println("\n✅ WiFi Connected!");

  // --- DHT ---
  dht.begin();

  // --- Firebase ---
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("✅ Firebase SignUp OK");
  } else {
    Serial.printf("❌ SignUp Error: %s\n", config.signer.signupError.message.c_str());
  }

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // --- Dust sensor ---
  pinMode(ledPower, OUTPUT);
  digitalWrite(ledPower, HIGH); // LED tắt mặc định
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

  voltage = dustVal * (3.3 / 4095.0); // ADC 12-bit ESP32-C3, 3.3V
  dustDensity = 0.172 * voltage - 0.1;
  if (dustDensity < 0) dustDensity = 0;
  if (dustDensity > 0.5) dustDensity = 0.5;

  // ----- Serial debug -----
  Serial.printf("T=%.1f°C H=%.1f%% MQ135=%d | Dust: %.3fV %.2f ug/m3\n",
                t, h, mq135Raw, voltage, dustDensity * 1000.0);

  // ----- Gửi Firebase (chỉ khi dữ liệu hợp lệ) -----
  if (Firebase.ready()) {
    if (!isnan(t) && !isnan(h)) {
      if (!Firebase.RTDB.setFloat(&fbdo, "ESP32C3/nhiet_do", t))
        Serial.println(fbdo.errorReason());

      if (!Firebase.RTDB.setFloat(&fbdo, "ESP32C3/do_am", h))
        Serial.println(fbdo.errorReason());
    } else {
      Serial.println("DHT read failed, skipping Firebase update");
    }

    if (!isnan(voltage) && !isnan(dustDensity)) {
      if (!Firebase.RTDB.setFloat(&fbdo, "ESP32C3/dust_voltage", voltage))
        Serial.println(fbdo.errorReason());

      if (!Firebase.RTDB.setFloat(&fbdo, "ESP32C3/dust_density", dustDensity * 1000.0))
        Serial.println(fbdo.errorReason());
    }

    // MQ135 luôn hợp lệ vì là int ADC
    if (!Firebase.RTDB.setInt(&fbdo, "ESP32C3/mq135_raw", mq135Raw))
      Serial.println(fbdo.errorReason());
  }

  delay(5000); // Lặp lại sau 5 giây
}
