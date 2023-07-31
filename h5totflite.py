import tensorflow as tf

# Load the Keras model from the .h5 file
model = tf.keras.models.load_model('.\models\skin_cancer_model4.h5')

# Optional: Check the summary of the Keras model
model.summary()

# Convert the model to TFLite format
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save the TFLite model to a file
with open('model.tflite', 'wb') as f:
    f.write(tflite_model)
