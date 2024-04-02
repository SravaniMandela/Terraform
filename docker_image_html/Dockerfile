# Use an official Python runtime as a base image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the index.html file into the container
COPY index.html /app

# Expose port 8000 to the outside world UR LOCALHOSTIP:CONTAINERIP (DOCKER FILE LOO KUDA WE USE CONTAINER IP)
EXPOSE 8000

# Run a simple HTTP server when the container starts
CMD ["python", "-m", "http.server", "8000"]
