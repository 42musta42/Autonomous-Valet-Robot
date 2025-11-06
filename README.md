# Autonomous Valet Robot

This repository contains the official source code and firmware for the research paper: **"A Prototype Autonomous Valet Robot with a Companion Mobile Application"** (IJIT-D-25-00457).

## Overview

This project is a functional proof-of-concept for an autonomous valet robot designed to operate in existing parking structures.The system integrates a user-facing mobile application, a high-level processor for AI and coordination, and a low-level microcontroller for real-time hardware control.

### Key Features
* **Mobile Application:** A Flutter-based app for user registration and parking/retrieval requests[cite: 2822].
* **Dual-Controller System:**
    * **Raspberry Pi 5 (Python):** Runs a Flask server to communicate with the app, coordinates high-level tasks, and performs computer vision inference.
    * **Arduino Mega (C++):** Handles all real-time, low-level hardware control, including motor drivers, IR line-following sensors, and servo actuation.
* **Computer Vision:** Uses the Roboflow API for two key tasks:
    1.  Real-time **Arabic License Plate Recognition (LPR)**.
    2.  **Parking Spot Detection**.

## Repository Structure (Firmware Details)

As requested by our reviewers (II.5), this repository provides the "firmware" and simulation files for reproduction.

* `/python-raspberry-pi/`: Contains the Python scripts (`main.py`, `flask_app.py`, etc.) for the Raspberry Pi 5. This code manages the Flask server, communicates with the Arduino via serial, and calls the Roboflow inference API.
* `/arduino-mega/`: Contains the Arduino (`.ino`) sketch for the Arduino Mega. This code is responsible for all low-level hardware control, including the PID logic for line following, controlling DC motors via H-bridges, and actuating the servo-driven lifting arms.
* [cite_start]`/matlab-simulation/`: Contains the MATLAB (`.m`) script used to generate the kinematic parking and exit simulations (Figures 7 & 8) presented in the paper [cite: 2863-2865].
