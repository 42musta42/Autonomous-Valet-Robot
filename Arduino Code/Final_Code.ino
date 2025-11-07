// === Valet Robot Arduino Code with Line Following and Parking Logic ===
#include <Servo.h>

// === Motor Control Pins ===
#define dirRight 22
#define dirLeft  23
#define pwmRightForward 2
#define pwmRightBackward 3
#define pwmLeftForward 4
#define pwmLeftBackward 5
#define speedVal 255

// === Servo Setup ===
int servoPins[6] = {52, 24, 26, 12, 51, 13};
Servo servos[6];

// === IR Sensor Pins (Analog) ===
int frontIR[5] = {A0, A1, A2, A3, A4}; // For forward movement
int backIR[5]  = {A5, A6, A7, A8, A9}; // For backward movement

// === Ultrasonic Pins ===
// Car detection
#define trigCar 30
#define echoCar 31
// Obstacle avoidance
#define trigLeft1 32
#define echoLeft1 33
#define trigLeft2 34
#define echoLeft2 35
#define trigRight1 36
#define echoRight1 37
#define trigRight2 38
#define echoRight2 39
#define trigFront 40
#define echoFront 41
#define trigBack 42
#define echoBack 43

char command;
bool waitingForP = false;
bool parkingMode = false;

void setup() {
  Serial.begin(9600);

  pinMode(dirRight, OUTPUT);
  pinMode(dirLeft, OUTPUT);
  pinMode(pwmRightForward, OUTPUT);
  pinMode(pwmRightBackward, OUTPUT);
  pinMode(pwmLeftForward, OUTPUT);
  pinMode(pwmLeftBackward, OUTPUT);

  for (int i = 0; i < 6; i++) {
    servos[i].attach(servoPins[i]);
    if (servoPins[i] == 28 || servoPins[i] == 51 || servoPins[i] == 13)
      servos[i].write(180);
    else
      servos[i].write(0);
  }

  int ultrasonicPins[] = {
    trigCar, echoCar, trigLeft1, echoLeft1, trigLeft2, echoLeft2,
    trigRight1, echoRight1, trigRight2, echoRight2,
    trigFront, echoFront, trigBack, echoBack
  };
  for (int i = 0; i < sizeof(ultrasonicPins)/sizeof(int); i++) {
    pinMode(ultrasonicPins[i], (i % 2 == 0) ? OUTPUT : INPUT);
  }
}

void loop() {
  if (Serial.available()) {
    command = Serial.read();

    if (command == 's') {
      waitingForP = true;
      followLineUntilCarDetected();
    }

    else if (command == 'p') {
      stopMotors();
      delay(1000);
      openServosOnly();
      delay(2000);
      Serial.println("z");
      waitingForP = false;
      followLineBackward();
    }

    else if (command == 'o') {
      stopMotors();
      delay(500);
      parkingMode = true;
      performParkingSequence();
      parkingMode = false;
    }

    else if (command == 'c') {
      stopMotors();
    }
  }
}

void followLineUntilCarDetected() {
  while (true) {
    followLineForward();
    float d = readUltrasonicCM(trigCar, echoCar);
    if (d > 0 && d < 22.5) {
      stopMotors();
      Serial.println("f");
      break;
    }
  }
}

void followLineForward() {
  int error = readLineError(frontIR);
  adjustMotors(error);
}

void followLineBackward() {
  unsigned long startTime = millis();
  while (millis() - startTime < 8000) {
    int error = readLineError(backIR);
    adjustMotors(-error);
  }
  stopMotors();
}

void performParkingSequence() {
  // Step 1: Move backward for 5 seconds
  unsigned long start1 = millis();
  while (millis() - start1 < 5000) {
    moveBackward();
  }

  // Step 2: Turn right for 2 seconds
  unsigned long start2 = millis();
  while (millis() - start2 < 2000) {
    turnRight();
  }

  // Step 3: Continue turning right until IR detects line
  while (true) {
    turnRight();
    int error = readLineError(frontIR);
    if (error != 0) break;
  }
  stopMotors();
  delay(500);

  // Step 4: Follow the parking line forward
  while (true) {
    followLineForward();
    float d = readUltrasonicCM(trigFront, echoFront);
    if (d > 0 && d < 10) {
      stopMotors();
      delay(500);
      closeServosOnly();
      delay(2000);
      break;
    }
  }

 // Step 5: Follow parking line backward until line ends
while (true) {
  int error = readLineError(backIR);
  if (error == 0) { // No line detected
    stopMotors();
    break;
  }
  adjustMotors(-error);
}


void moveBackward() {
  digitalWrite(dirRight, HIGH);
  digitalWrite(dirLeft, HIGH);
  analogWrite(pwmRightBackward, speedVal);
  analogWrite(pwmLeftBackward, speedVal);
}

void turnRight() {
  digitalWrite(dirRight, HIGH);
  digitalWrite(dirLeft, HIGH);
  analogWrite(pwmRightForward, 0);
  analogWrite(pwmLeftForward, speedVal);
}

int readLineError(int pins[]) {
  int weights[5] = {-2, -1, 0, 1, 2};
  int total = 0, active = 0;
  for (int i = 0; i < 5; i++) {
    int val = analogRead(pins[i]);
    if (val < 500) {
      total += weights[i];
      active++;
    }
  }
  return active ? total / active : 0;
}

void adjustMotors(int error) {
  int base = speedVal;
  int correction = error * 30;
  int leftSpeed = constrain(base - correction, 0, 255);
  int rightSpeed = constrain(base + correction, 0, 255);
  digitalWrite(dirRight, HIGH);
  digitalWrite(dirLeft, HIGH);
  analogWrite(pwmRightForward, rightSpeed);
  analogWrite(pwmLeftForward, leftSpeed);
}

void openServosOnly() {
  for (int angle = 0; angle <= 90; angle++) {
    for (int i = 0; i < 6; i++) {
      if (servoPins[i] == 28 || servoPins[i] == 51 || servoPins[i] == 13)
        servos[i].write(180 - angle);
      else
        servos[i].write(angle);
    }
    delay(15);
  }
}

void closeServosOnly() {
  for (int angle = 90; angle >= 0; angle--) {
    for (int i = 0; i < 6; i++) {
      if (servoPins[i] == 28 || servoPins[i] == 51 || servoPins[i] == 13)
        servos[i].write(180 - angle);
      else
        servos[i].write(angle);
    }
    delay(15);
  }
}

void stopMotors() {
  analogWrite(pwmRightForward, 0);
  analogWrite(pwmRightBackward, 0);
  analogWrite(pwmLeftForward, 0);
  analogWrite(pwmLeftBackward, 0);
}

float readUltrasonicCM(int trig, int echo) {
  digitalWrite(trig, LOW);
  delayMicroseconds(2);
  digitalWrite(trig, HIGH);
  delayMicroseconds(10);
  digitalWrite(trig, LOW);
  long duration = pulseIn(echo, HIGH, 30000);
  return duration * 0.034 / 2;
}

void checkObstacles() {
  float left1 = readUltrasonicCM(trigLeft1, echoLeft1);
  float left2 = readUltrasonicCM(trigLeft2, echoLeft2);
  float right1 = readUltrasonicCM(trigRight1, echoRight1);
  float right2 = readUltrasonicCM(trigRight2, echoRight2);
  float front = readUltrasonicCM(trigFront, echoFront);
  if ((left1 < 15 && left1 > 0) || (left2 < 15 && left2 > 0) ||
      (right1 < 15 && right1 > 0) || (right2 < 15 && right2 > 0) ||
      (front < 15 && front > 0)) {
    stopMotors();
    delay(500);
  }
}
