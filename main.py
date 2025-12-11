from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import tensorflow as tf
import numpy as np
from PIL import Image
import os

# ==========================================
# CONFIGURACIÓN DEL MODELO
# ==========================================
# Ruta relativa dentro del proyecto
MODEL_PATH = os.environ.get("MODEL_PATH", "model_files/model_0.904.keras")

# Cargar modelo
model = tf.keras.models.load_model(MODEL_PATH)

# Clases del modelo
class_names = ["Glioma", "Meningioma", "No Tumor", "Pituitary"]

IMG_SIZE = (224, 224)

# ==========================================
# APP FASTAPI
# ==========================================
app = FastAPI(title="MRI Tumor Classifier API")

# Habilitar CORS (importante para Streamlit online)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],       # luego puedes restringirlo
    allow_methods=["*"],
    allow_headers=["*"],
)


# ==========================================
# FUNCIÓN DE PREDICCIÓN
# ==========================================
def predict(image: Image.Image):
    image = image.resize(IMG_SIZE)
    img_array = np.array(image) / 255.0
    img_array = np.expand_dims(img_array, axis=0)

    preds = model.predict(img_array)[0]  # vector de 4 probabilidades
    idx = np.argmax(preds)

    prob_dict = {class_names[i]: float(preds[i]) for i in range(len(class_names))}
    return class_names[idx], float(preds[idx]), prob_dict


# ==========================================
# ENDPOINT PRINCIPAL
# ==========================================
@app.post("/predict")
async def predict_image(file: UploadFile = File(...)):
    img = Image.open(file.file).convert("RGB")
    label, prob, probs_dict = predict(img)

    return JSONResponse({
        "prediction": label,
        "confidence": round(prob, 3),
        "probabilities": probs_dict
    })
