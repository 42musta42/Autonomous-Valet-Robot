from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import Sequence

db = SQLAlchemy()

class users(db.Model):
    __tablename__ = 'users'
    uid = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(50))
    email = db.Column(db.String(70))
    phoneNumber = db.Column(db.String(20))
    password = db.Column(db.String(25))
    address = db.Column(db.String(100))
    documentId = db.Column(db.String(50))
    documentSource = db.Column(db.String(100))
    carType = db.Column(db.String(45))
    carModel = db.Column(db.String(80))
    carLetters = db.Column(db.String(80))
    carNumbers = db.Column(db.String(15))
    carChassis = db.Column(db.String(20))
    def __repr__(self):
        return f"<User uid={self.uid}, username={self.username}, email={self.email}, " \
               f"phoneNumber={self.phoneNumber}, password={self.password}, address={self.address}, " \
               f"documentId={self.documentId}, documentSource={self.documentSource}, " \
               f"carType={self.carType}, carModel={self.carModel}, carLetters={self.carLetters}, " \
               f"carNumbers={self.carNumbers}, carChassis={self.carChassis}>"
