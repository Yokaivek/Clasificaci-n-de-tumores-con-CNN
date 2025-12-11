# 1. Elegir una imagen base de Python (estable y con herramientas)
# Usamos esta base porque incluye 'git' y 'apt'
FROM python:3.10-slim

# Reemplaza con la URL COMPLETA de tu repositorio de GitHub
ARG GITHUB_REPO_URL="https://github.com/Yokaivek/Clasificaci-n-de-tumores-con-CNN.git"

# 2. Instalar Git LFS y otras herramientas necesarias
RUN apt-get update && apt-get install -y git-lfs \
    && rm -rf /var/lib/apt/lists/*

# 3. Establecer el directorio de trabajo (donde estará el código final)
WORKDIR /app

# 4. Clonar todo el repositorio (esto se encargará de Git LFS automáticamente)
# Esto garantiza que el contexto de Git exista y se descargue el modelo LFS
RUN git clone --depth 1 $GITHUB_REPO_URL .

# 5. Instalar dependencias (basadas en el requirements.txt que acaba de ser clonado)
RUN pip install --no-cache-dir -r requirements.txt

# 6. Exponer el puerto
EXPOSE 8080

# 7. Comando de inicio
# El modelo ya está disponible en model_files/
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]