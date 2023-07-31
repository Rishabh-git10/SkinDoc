# SkinDoc
A Flutter App that enables the user to click a photo/upload from gallery of a Skin Lesion, and determine, what type of Skin Lesion it is, or even if it is the result of Skin Cancer.
It classifies the image into one of these 7 classes :
    <li>
    bkl: Benign Keratosis-like Lesions,
    <li>
    nv: Melanocytic Nevi (Moles),
    df: Dermatofibroma,
    <li>
    mel: Melanoma,
    <li>
    vasc: Vascular Skin Lesions,
    <li>
    bcc: Basal Cell Carcinoma,
    <li>
    akiec: Actinic Keratoses and Intraepidermal Carcinoma

    
while also determines if it's cancerous or not.

## Overview
<p>The app uses [HAM10000](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/DBW86T)
 dataset for detecting Pigmented Skin Lesions from Harvard Dataverse and uses the pre-trained MobileNet model from Keras to create a model for the purpose of classification.</p>
 <p>The model is converted from .h5 format to .tflite format and used in the Flutter app SkinDoc using tflite_flutter package.</p>
 <p>
 SkinDoc provides a way to click the image or upload it from the gallery, and then after preprocesssing the image, the image is fed to the model, which gives out the prediction.</p>
 <p>SkinDoc also provides random tips, to prevent from Skin Cancer, although it is hard coded, for now, but will be updated soon, to fetch random tips from the internet.</p>
 
 ## How to use the app

 



