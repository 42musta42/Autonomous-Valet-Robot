# Autonomous Valet Robot

This repository contains the official source code and firmware for the research paper: **"A Prototype Autonomous Valet Robot with a Companion Mobile Application"** (IJIT-D-25-00457).

## Overview

[cite_start]This project is a functional proof-of-concept for an autonomous valet robot designed to operate in existing parking structures[cite: 2722]. [cite_start]The system integrates a user-facing mobile application, a high-level processor for AI and coordination, and a low-level microcontroller for real-time hardware control [cite: 2781, 2784-2790].

### Key Features
* [cite_start]**Mobile Application:** A Flutter-based app for user registration and parking/retrieval requests[cite: 2822].
* **Dual-Controller System:**
    * [cite_start]**Raspberry Pi 5 (Python):** Runs a Flask server to communicate with the app, coordinates high-level tasks, and performs computer vision inference[cite: 2786, 2796].
    * [cite_start]**Arduino Mega (C++):** Handles all real-time, low-level hardware control, including motor drivers, IR line-following sensors, and servo actuation[cite: 2790, 2800].
* **Computer Vision:** Uses the Roboflow API for two key tasks:
    1.  [cite_start]Real-time **Arabic License Plate Recognition (LPR)** [cite: 2729-2735].
    2.  [cite_start]**Parking Spot Detection** [cite: 2736-2742].

## Repository Structure (Firmware Details)

As requested by our reviewers (II.5), this repository provides the "firmware" and simulation files for reproduction.

* `/python-raspberry-pi/`: Contains the Python scripts (`main.py`, `flask_app.py`, etc.) for the Raspberry Pi 5. This code manages the Flask server, communicates with the Arduino via serial, and calls the Roboflow inference API.
* `/arduino-mega/`: Contains the Arduino (`.ino`) sketch for the Arduino Mega. This code is responsible for all low-level hardware control, including the PID logic for line following, controlling DC motors via H-bridges, and actuating the servo-driven lifting arms.
* [cite_start]`/matlab-simulation/`: Contains the MATLAB (`.m`) script used to generate the kinematic parking and exit simulations (Figures 7 & 8) presented in the paper [cite: 2863-2865].
