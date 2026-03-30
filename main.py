"""
main.py
-------
GitOps Capstone — Microservice API
Author : Muathaf
Purpose: A minimal, production-ready FastAPI microservice.
         Designed to be containerized with Docker and
         orchestrated with Kubernetes.
"""

from fastapi import FastAPI
from datetime import datetime

# ─────────────────────────────────────────
# APP CONFIGURATION
# ─────────────────────────────────────────

# Application version — update this when you release a new build.
# In a real GitOps pipeline this would be injected at build time
# via an environment variable or CI/CD step.
APP_VERSION = "1.0.0"

# Initialize the FastAPI application
app = FastAPI(
    title="Muathaf GitOps Microservice",
    description="A containerized microservice for the GitOps Capstone project.",
    version=APP_VERSION,
)


# ─────────────────────────────────────────
# ROUTES
# ─────────────────────────────────────────

@app.get("/")
def root():
    """
    Root endpoint.
    Returns a basic welcome message so the service
    is identifiable when accessed directly.
    """
    return {
        "service": "Muathaf GitOps Microservice",
        "version": APP_VERSION,
        "docs":    "/docs",
    }


@app.get("/health")
def health_check():
    """
    Health check endpoint.
    Used by Kubernetes liveness and readiness probes
    to confirm the service is running correctly.

    Returns:
        status  : 'Healthy' if the service is operational.
        version : Current application version.
        time    : UTC timestamp of the health check request.
    """
    return {
        "status":  "Healthy",
        "version": APP_VERSION,
        "time":    datetime.utcnow().isoformat() + "Z",
    }