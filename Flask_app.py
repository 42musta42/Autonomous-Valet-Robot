from flask import Flask, request, jsonify
from config import ApplicationConfig
from flask_db import db, users
import subprocess

# Temporary storage
latest_car_info = {}
latest_letter = None
latest_user_id = None

app = Flask(__name__)
app.config.from_object(ApplicationConfig)
db.init_app(app)

with app.app_context():
    db.create_all()

def restart_robot_service():
    try:
        subprocess.run(["sudo", "systemctl", "restart", "robot-main.service"], check=True)
        print("robot-main.service restarted successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Failed to restart service: {e}")

@app.route('/')
def home():
    cars = users.query.all()
    car_list = ''
    for car in cars:
        car_list += f'''
            <b>UID:</b> {car.uid}<br>
            <b>Username:</b> {car.username}<br>
            <b>Email:</b> {car.email}<br>
            <b>Phone Number:</b> {car.phoneNumber}<br>
            <b>Address:</b> {car.address}<br>
            <b>Document ID:</b> {car.documentId}<br>
            <b>Document Source:</b> {car.documentSource}<br>
            <b>Car Type:</b> {car.carType}<br>
            <b>Car Model:</b> {car.carModel}<br>
            <b>Car Letters:</b> {car.carLetters}<br>
            <b>Car Numbers:</b> {car.carNumbers}<br>
            <b>Car Chassis:</b> {car.carChassis}<br>
            <hr>
            ...
    return car_list
@app.route('/car-info', methods=['GET'])
def receive_car_info():
    global latest_user_id
    if not latest_user_id:
        return jsonify({'error': 'No user ID available'}), 400

    user = users.query.get(latest_user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404

    car_letters = user.carLetters
    car_numbers = user.carNumbers

    latest_car_info['carLetters'] = car_letters
    latest_car_info['carNumbers'] = car_numbers

    print(f"Received car letters: {car_letters}", flush=True)
    print(f"Received car numbers: {car_numbers}", flush=True)

    return jsonify({
        'message': 'Car info received',
        'carLetters': car_letters,
        'carNumbers': car_numbers
    }), 200

@app.route('/send-letter', methods=['POST'])
def receive_letter():
    global latest_letter
    data = request.json
    letter = data.get('letter')
    if letter:
        latest_letter = letter
        print(f"Received letter: {letter}", flush=True)
        return jsonify({'message': f"Letter '{letter}' received successfully."}), 200
    else:
        return jsonify({'error': 'No letter received'}), 400
@app.route('/get-letter', methods=['GET'])
def get_letter():
    if latest_letter:
        return jsonify({'letter': latest_letter}), 200
    return jsonify({'error': 'No letter available'}), 404

@app.route('/signup', methods=['POST'])
def signup():
     global latest_user_id
    data = request.json
    try:
        new_user = users(
            username=data['username'],
            email=data['email'],
            phoneNumber=data['phoneNumber'],
            password=data['password'],
            address=data['address'],
            documentId=data['documentId'],
            documentSource=data['documentSource'],
            carType=data['carType'],
            carModel=data['carModel'],
            carLetters=data['carLetters'],
            carNumbers=data['carNumbers'],
            carChassis=data['carChassis']
        )
        db.session.add(new_user)
        db.session.commit()
        latest_user_id = new_user.uid
        print(f"Latest user id saved: {latest_user_id}")
        restart_robot_service()
        return jsonify({'message': 'User registered successfully'}), 201
    except Exception as e:
        db.session.rollback()
        import traceback
        print("Exception during signup:", flush=True)
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
