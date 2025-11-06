import cv2
from picamera2 import Picamera2
from roboflow import Roboflow
from inference_sdk import InferenceHTTPClient
import time
import requests
import unicodedata
import serial

# URLs
FLASK_URL = "http://localhost:5000/car-info"
LETTER_URL = "http://localhost:5000/get-letter"
LETTER_G_URL = "http://localhost:5000/get-letter-g"

# Arabic map
class_to_arabic = {
    'alef': 'أ', 'b': 'ب', 'teh': 'ة', 'theh': 'ث', 'jeem': 'ج', 'hah': 'ح',
    'khah': 'خ', 'd': 'د', 'thal': 'ذ', 'r': 'ر', 'zain': 'ز', 'seen': 'س',
    'sheen': 'ش', 'sad': 'ص', 'dad': 'ض', 't': 'ط', 'zah': 'ظ', 'ain': 'ع',
    'ghain': 'غ', 'feh': 'ف', 'qaf': 'ق', 'kaf': 'ك', 'lam': 'ل', 'meem': 'م',
    'non': 'ن', 'heh': 'ه', 'w': 'و', 'y': 'ي',
    '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤', '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩'
}

flutter_letter = ""
car_letters = ""
car_numbers = ""

def setup_serial_connection():
    global arduino, picam_plate, picam_parking, parking_model, plate_model, rf
    # Setup serial connection to Arduino
    try:
        arduino = serial.Serial('/dev/ttyACMO', 9600, timeout=1)
        time.sleep(2)
        print(" Arduino connected.")
        #return arduino
    except Exception as e:
        print(f"X Error connecting to Arduino: {e}")
        arduino = None
        #return None
    #Initialize models
    rf = Roboflow(api_key="ekmKpC7VrTsoXcjyTdJn")
    parking_model = InferenceHTTPClient(api_url="https://detect.roboflow.com", api_key="ekmKpC7VrTsoXcjyTdJn")
    plate_model = InferenceHTTPClient(api_url="https://detect.roboflow.com", api_key="ekmKpC7VrTsoXcjyTdJn")


# Init cameras
picam_plate = Picamera2(camera_num=0)
picam_parking = Picamera2(camera_num=1)

for cam in [picam_plate, picam_parking]:
    cam.preview_configuration.main.size = (320, 240)
    cam.preview_configuration.main.format = "RGB888"
    cam.preview_configuration.align()
    cam.configure("preview")
    cam.start()

return arduino, picam_plate, picam_parking

def normalize_arabic_text(text):
    return unicodedata.normalize('NFC', text)

def plate_park(car_letters, car_numbers):
    global arduino, picam_plate, plate_model, arduino
    plate_path = "/tmp/plate.jpg"
    plate_matched = False

    while not plate_matched:
        frame = picam_plate.capture_array()
        cv2.imwrite(plate_path, frame)

        result = plate_model.infer(plate_path, model_id="merged1-yearb/1")
        predictions = result.get("predictions", [])

        for pred in predictions:
            x, y, w, h = int(pred["x"]), int(pred["y"]), int(pred["width"]), int(pred["height"])
            cls = pred.get("class", "")
            top_left = (x - w // 2, y - h // 2)
            bottom_right = (x + w // 2, y + h // 2)
            cv2.rectangle(frame, top_left, bottom_right, (0, 255, 0), 2)
            cv2.putText(frame, cls, (top_left[0], top_left[1] - 5),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)

        cv2.imshow("Plate Detection Camera", frame)
        predictions = sorted(predictions, key=lambda x: x["x"])

        det_letters = ""
        det_numbers = ""

        letters, numbers = [], []
        for pred in predictions:
            cls = pred.get("class", "")
            arabic_char = class_to_arabic.get(cls, '')
            if arabic_char == '':
                continue
            if cls.isdigit():
                det_numbers += arabic_char
            else:
                det_letters += arabic_char

        det_letters = normalize_arabic_text(det_letters)
        det_numbers = normalize_arabic_text(det_numbers)
        print(f" Letters: {det_letters} | Numbers: {det_numbers}")

        if det_letters == normalize_arabic_text(car_letters) and \
           det_numbers == normalize_arabic_text(car_numbers):
            print(" Plate matched!")
            plate_matched = True
        else:
            print("X Plate not matched.")

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    cv2.destroyWindow("Plate Detection Camera")
    return plate_matched

def parking_detection():
    global arduino, picam_parking, parking_model
    parking_path = "/tmp/parking.jpg"
    parking_detected = False

    while not parking_detected:
        frame = picam_parking.capture_array()
        cv2.imwrite(parking_path, frame)

        start = time.time()
        result = parking_model.infer(parking_path, model_id="parking-2-j6rqq/3")
        print(f" Detection took {time.time() - start:.2f} seconds")
        predictions = result.get("predictions", [])
        for pred in predictions:
            x, y, w, h = int(pred["x"]), int(pred["y"]), int(pred["width"]), int(pred["height"])
        cls = pred.get("class", "")
        conf = pred.get("confidence", 0)
        top_left = (x - w // 2, y - h // 2)
        bottom_right = (x + w // 2, y + h // 2)

        # Green box for empty, red for others
        color = (0, 255, 0) if cls.lower() == "empty" else (0, 0, 255)
        cv2.rectangle(frame, top_left, bottom_right, color, 2)
        cv2.putText(frame, f"{cls} (conf:.2f)", (top_left[0], top_left[1] - 5),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 1)

        if cls.lower() == "empty" and conf > 0.3:
            print(" Empty parking detected!")
            parking_detected = True

    cv2.imshow("Parking Detection Camera", frame)

    # Always wait at least 1 second per frame
    if parking_detected:
        print("II Showing detection result for 5 seconds...")
        cv2.waitKey(5000)
    else:
        cv2.waitKey(1000) # Slower loop so human eyes can see

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
cv2.destroyWindow("Parking Detection Camera")
return parking_detected

def return_car(car_letters, car_numbers):
    global arduino
    Is_car_returned = False
    while not Is_car_returned:
        r_g = requests.get(LETTER_G_URL)
        if r_g.status_code == 200:
            flutter_letter = r_g.json().get("letter", "")
            if flutter_letter == "g":
                print(" New 'g' detected. Starting return process.")
                if arduino:
                    arduino.write(b'g')
                    print(" Sent 'g' to Arduino.")

                print(" [Return] Waiting for Arduino to send '1'...")
                while True:
                    try:
                        line = arduino.readline().decode().strip()
                        if line == "1":
                            print(" [Return] Arduino: I will return to the car position.")
                            arduino.write(b'l')
                            print(" Sent 'l' to Arduino to activate plate detection.")
                            break
                    except Exception as e:
                        print(f"X Error reading 'l': {e}")
                        time.sleep(0.2)
            
            print(" [Return] Activating plate camera to locate car...")
            plate_matched_return = plate_park(car_letters, car_numbers)
            if plate_matched_return:
                if arduino:
                    arduino.write(b'r')
                    print(" Sent 'r' to Arduino to return the car.")
                    Is_car_returned = True
                    print(" Car returned successfully!")
            else:
                print("X Plate detection failed during return. Exiting.")
                exit(1)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

    return Is_car_returned

# --- MAIN FUNCTION ---
if __name__ == "__main__":
    arduino, picam_plate, picam_parking = setup_serial_connection()

    # --- WAIT FOR 's' OR 'g' FROM FLUTTER ---
    print(" Waiting for Flutter to send 's' or 'g'...")
    while flutter_letter not in ["s", "g"]:
        try:
            car_info = requests.get(FLASK_URL)
            if car_info.status_code == 200:
                data = car_info.json()
                car_letters = data.get("carLetters", "")[::-1] # Fix reversed letters
                car_numbers = data.get("carNumbers", "")
                print(f" Updated Car info: {car_letters} - {car_numbers}")

            letter_info = requests.get(LETTER_URL)
            if letter_info.status_code == 200:
                flutter_letter = letter_info.json().get("letter", "")
                print(f" Received Flutter letter: {flutter_letter}")
     except Exception as e:
                print(f"X Error polling Flask: {e}")

        time.sleep(1)

    print(f" Car Letters: {car_letters} | Car Numbers: {car_numbers} | Flutter Letter: {flutter_letter}")

    # --- START ---
    if flutter_letter == "s" and arduino:
        arduino.write(b's')
        print(" Sent 's' to Arduino.")
    
    elif flutter_letter == "g" and arduino:
        arduino.write(b'g')
        print(" Sent 'g' to Arduino.")
        # return process handled below after loop (reuse)

    # --- WAIT FOR 'f' FROM ARDUINO ---
    print(" Waiting for Arduino to send 'f'...")
    while True:
        try:
            line = arduino.readline().decode().strip()
            if line == "f":
                print(" Got 'f'. Start plate detection.")
                plate_matched = plate_park(car_letters, car_numbers)
                break
        except Exception as e:
            print(f"X Error reading from Arduino: {e}")
            time.sleep(0.2)

    # --- PLATE DETECTION ---
    if plate_matched:
        if arduino:
            arduino.write(b'p')
            print(" Sent 'p' to Arduino.")
    else:
        print("X Plate detection failed. Exiting.")
        exit(1)

    # --- WAIT FOR 'z' FROM ARDUINO ---
    print(" Waiting for Arduino to send 'z'...")
    while True:
        try:
            line = arduino.readline().decode().strip()
            if line == "z":
                print(" Got 'z'. Start parking detection.")
                parking_detected = parking_detection()
                break
        except Exception as e:
            print(f"X Error reading from Arduino: {e}")
            time.sleep(0.2)

    # --- PARKING DETECTION ---
    if parking_detected:
        if arduino:
            arduino.write(b'o')
            print(" Sent 'o' to Arduino to indicate parking found")
    else:
        print("X Parking detection failed. Exiting.")
        exit(1)

    print(" Done: Plate matched & Parking found!")

    # --- CONTINUOUS RETURN LISTENER ---
    print(" Waiting for possible return signal 'g' from Flutter...")
    car_returned = return_car(car_letters, car_numbers)
    if car_returned:
        print("Ending.....")
        if arduino:
            arduino.close()
    else:
        print("X Car return failed.")
