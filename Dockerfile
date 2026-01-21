# Use the official lightweight Python image.
FROM python:3.9-slim

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Set the working directory to /app
ENV APP_HOME /app
WORKDIR $APP_HOME

# 1. Copy the requirements file specifically from the backend folder
COPY backend/requirements.txt ./

# 2. Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# 3. Copy the rest of the backend code into the container
COPY backend/ ./

# Run the web service on container startup.
# Timeout is set to 0 to allow Cloud Run to handle instance scaling.
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app