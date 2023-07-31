# SkinDoc
A Flutter App that enables the user to click a photo/upload from gallery of a Skin Lesion, and determine, what type of Skin Lesion it is, or even if it is the result of Skin Cancer.
It classifies the image into one of these 7 classes :

   1. bkl: Benign Keratosis-like Lesions,

   2. nv: Melanocytic Nevi (Moles),

   3. df: Dermatofibroma,
    
   4. mel: Melanoma,
    
   5. vasc: Vascular Skin Lesions,
    
   6. bcc: Basal Cell Carcinoma,
    
   7. akiec: Actinic Keratoses and Intraepidermal Carcinoma

while also determines if it's cancerous or not.

## Overview

The app uses [HAM10000]() dataset for detecting Pigmented Skin Lesions from Harvard Dataverse and uses the pre-trained MobileNet model from Keras to create a model for the purpose of classification.

The model is converted from .h5 format to .tflite format and used in the Flutter app SkinDoc using tflite_flutter package.

SkinDoc provides a way to click the image or upload it from the gallery, and then after preprocesssing the image, the image is fed to the model, which gives out the prediction.

SkinDoc also provides random tips, to prevent from Skin Cancer, although it is hard coded, for now, but will be updated soon, to fetch random tips from the internet.

## Features and Interfaces

### Home Screen

Implemented a simple UI design, with a logo, and three buttons:

    1. Check Skin Lesion
    2. Skin Cancer Tips
    3. Exit

 ## How to use the app

Download the SkinDoc.apk file from the repository and use directly.

## How to run the Project

### Install Flutter and it's other dependencies.

Follow the instruction mentioned in [this](https://docs.flutter.dev/get-started/install) website according to your operating system.

Run <code>flutter doctor</code> in the terminal to check if all the dependencies are installed.

Ensure tick mark in all the dependencies, if not follow the instructions provided below the dependency in the terminal.

### Cloning the project

Press the drop down Code button and copy the http link and use `git clone 'http link here'` to clone the project.

### Running the project

After installing all the dependencies, open `skindoc/lib/main.dart` and configure device in the bottom right corner (for vscode) then go to `Run => Start Debugging (F5)`.

This will start the app in your device, whether it be virtual or the one you connected to the computer using the instructions from the previous step.

## Contributing to the project

For contribution to the project, follow these instructions:

1. Create a separate branch for your feature.

2. For new feature follow [these](https://dart.dev/effective-dart/style) guidelines.

3. The naming of classes and functions should reflect their application.

## Tech Stack Used

[![My Skills](https://skillicons.dev/icons?i=python,dart,flutter&theme=light)](https://skillicons.dev)




