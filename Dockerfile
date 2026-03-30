# ─────────────────────────────────────────
# Dockerfile — GitOps Capstone Microservice
# Author: Muathaf
# ─────────────────────────────────────────

# Stage 1: Use the official slim Python image as the base.
# 'slim' removes unnecessary build tools, keeping the image small
# and reducing the attack surface in production.
FROM python:3.13-slim

# ─────────────────────────────────────────
# ENVIRONMENT VARIABLES
# ─────────────────────────────────────────

# Prevents Python from writing .pyc files to disk (keeps container clean)
ENV PYTHONDONTWRITEBYTECODE=1

# Prevents Python from buffering stdout/stderr
# (ensures logs appear in real time in Docker and Kubernetes)
ENV PYTHONUNBUFFERED=1

# ─────────────────────────────────────────
# WORKING DIRECTORY
# ─────────────────────────────────────────

# Set the working directory inside the container.
# All subsequent commands run from here.
WORKDIR /app

# ─────────────────────────────────────────
# DEPENDENCIES
# ─────────────────────────────────────────

# Copy requirements first — before copying app code.
# This is a Docker best practice: if requirements haven't changed,
# Docker uses the cached layer and skips re-installing packages,
# making rebuilds significantly faster.
COPY requirements.txt .

# Install dependencies without caching pip downloads
# to keep the final image size as small as possible.
RUN pip install --no-cache-dir -r requirements.txt

# ─────────────────────────────────────────
# APPLICATION CODE
# ─────────────────────────────────────────

# Copy the application source code into the container.
# Doing this after pip install preserves the dependency cache layer.
COPY main.py .

# ─────────────────────────────────────────
# RUNTIME CONFIGURATION
# ─────────────────────────────────────────

# Document which port the application listens on.
# This does not publish the port — that is handled by Docker
# or Kubernetes at runtime.
EXPOSE 8000

# ─────────────────────────────────────────
# STARTUP COMMAND
# ─────────────────────────────────────────

# Start the FastAPI app using Uvicorn.
# --host 0.0.0.0 : Accept connections from outside the container.
# --port 8000    : Match the EXPOSE directive above.
# No --reload    : Reload is for development only, not production.
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
