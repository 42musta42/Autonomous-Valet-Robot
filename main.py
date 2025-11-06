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
