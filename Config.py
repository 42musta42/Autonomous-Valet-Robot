class ApplicationConfig:
    # PostgreSQL connection config
    DB_PASSWORD = 'adminroot'

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ECHO = True
    SQLALCHEMY_DATABASE_URI = f'postgresql://postgres:{DB_PASSWORD}@localhost:5432/car_app'
