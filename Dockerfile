# 1. Elegir una imagen base de Python (estable y con herramientas)
FROM python:3.10-slim

# Establecer la variable de entorno para que los logs de Python sean visibles inmediatamente
ENV PYTHONUNBUFFERED 1

# 2. Instalar Git LFS y otras herramientas necesarias
# 'git' ya está en la imagen 'slim', pero necesitamos instalar 'git-lfs'
# Esto se hace con el gestor de paquetes de la imagen base (apt-get)
RUN apt-get update && apt-get install -y git-lfs \
    && rm -rf /var/lib/apt/lists/*

# 3. Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# 4. Copiar los archivos de requisitos e instalar dependencias primero (para mejor caché)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copiar el resto de los archivos del proyecto (incluyendo main.py y el modelo .keras)
COPY . .

# 6. Descargar el contenido real de los archivos LFS
# Esto es CRUCIAL para que el modelo esté disponible antes de que main.py lo cargue
RUN git lfs pull

# 7. Exponer el puerto que usará Uvicorn
EXPOSE 8080

# 8. Comando de inicio (similar al Procfile)
# Railway inyectará la variable $PORT si es necesario. Usaremos 8080 como fallback.
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]