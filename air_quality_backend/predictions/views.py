from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import PredictionResult, DataPoint
from .serializers import PredictionResultSerializer, DataPointSerializer
import joblib
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
import os


# Load models and scalers
def load_models():
    models = {}
    scalers = {}

    # Get the project root directory (parent of air_quality_backend)
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    # Load ground model
    ground_model_path = os.path.join(project_root, "ground_model.pkl")
    ground_scaler_path = os.path.join(project_root, "ground_scaler.pkl")

    if os.path.exists(ground_model_path):
        models["ground"] = joblib.load(ground_model_path)
        scalers["ground"] = joblib.load(ground_scaler_path)

    # Load satellite model
    satellite_model_path = os.path.join(project_root, "satellite_model.pkl")
    satellite_scaler_path = os.path.join(project_root, "satellite_scaler.pkl")

    if os.path.exists(satellite_model_path):
        models["satellite"] = joblib.load(satellite_model_path)
        scalers["satellite"] = joblib.load(satellite_scaler_path)

    return models, scalers


models, scalers = load_models()


@api_view(["GET"])
def get_predictions(request):
    """Get predictions for both ground and satellite data"""
    try:
        predictions = {}

        # Get ground prediction
        if "ground" in models:
            ground_prediction = predict_next_7_days("ground")
            if ground_prediction is not None:
                predictions["ground"] = {
                    "prediction": ground_prediction,
                    "confidence": 0.85,  # Placeholder confidence
                    "model_name": "RandomForest",
                    "data_type": "ground",
                }

        # Get satellite prediction
        if "satellite" in models:
            satellite_prediction = predict_next_7_days("satellite")
            if satellite_prediction is not None:
                predictions["satellite"] = {
                    "prediction": satellite_prediction,
                    "confidence": 0.80,  # Placeholder confidence
                    "model_name": "RandomForest",
                    "data_type": "satellite",
                }

        return Response(predictions, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def predict_custom(request):
    """Make prediction with custom input parameters"""
    try:
        data = request.data

        # Extract parameters
        so2_mean = float(data.get("so2_mean", 0))
        so2_std = float(data.get("so2_std", 0))
        so2_min = float(data.get("so2_min", 0))
        so2_max = float(data.get("so2_max", 0))
        so2_median = float(data.get("so2_median", 0))
        year = int(data.get("year", datetime.now().year))
        month = int(data.get("month", datetime.now().month))
        day = int(data.get("day", datetime.now().day))
        day_of_week = int(data.get("day_of_week", datetime.now().weekday()))
        hour = int(data.get("hour", datetime.now().hour))

        # Create feature vector
        feature_vector = [
            so2_mean,
            so2_std,
            so2_min,
            so2_max,
            so2_median,
            year,
            month,
            day,
            day_of_week,
            hour,
            np.sin(2 * np.pi * month / 12),
            np.cos(2 * np.pi * month / 12),
            np.sin(2 * np.pi * day / 31),
            np.cos(2 * np.pi * day / 31),
            np.sin(2 * np.pi * hour / 24),
            np.cos(2 * np.pi * hour / 24),
        ]

        predictions = {}

        # Make prediction with ground model
        if "ground" in models:
            feature_vector_scaled = scalers["ground"].transform([feature_vector])
            ground_prediction = models["ground"].predict(feature_vector_scaled)[0]
            predictions["ground"] = {
                "prediction": ground_prediction,
                "confidence": 0.85,
                "model_name": "RandomForest",
                "data_type": "ground",
            }

        # Make prediction with satellite model
        if "satellite" in models:
            feature_vector_scaled = scalers["satellite"].transform([feature_vector])
            satellite_prediction = models["satellite"].predict(feature_vector_scaled)[0]
            predictions["satellite"] = {
                "prediction": satellite_prediction,
                "confidence": 0.80,
                "model_name": "RandomForest",
                "data_type": "satellite",
            }

        return Response(predictions, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["GET"])
def get_data_points(request):
    """Get recent data points for visualization"""
    try:
        data_type = request.GET.get("type", "both")
        limit = int(request.GET.get("limit", 100))

        if data_type == "both":
            data_points = DataPoint.objects.all()[:limit]
        else:
            data_points = DataPoint.objects.filter(data_type=data_type)[:limit]

        serializer = DataPointSerializer(data_points, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["GET"])
def get_model_info(request):
    """Get information about available models"""
    try:
        model_info = {}

        if "ground" in models:
            model_info["ground"] = {
                "available": True,
                "model_type": "RandomForest",
                "features": 16,
                "last_trained": "2024-01-01",  # Placeholder
            }
        else:
            model_info["ground"] = {"available": False}

        if "satellite" in models:
            model_info["satellite"] = {
                "available": True,
                "model_type": "RandomForest",
                "features": 16,
                "last_trained": "2024-01-01",  # Placeholder
            }
        else:
            model_info["satellite"] = {"available": False}

        return Response(model_info, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


def predict_next_7_days(data_type):
    """Predict next 7 days using the last 7 days of data"""
    try:
        # Get the last 7 days of data from the database
        seven_days_ago = datetime.now() - timedelta(days=7)
        recent_data = DataPoint.objects.filter(
            data_type=data_type, timestamp__gte=seven_days_ago
        ).order_by("timestamp")

        if len(recent_data) < 7:
            return None

        # Create feature vector from recent data
        so2_values = [point.so2_value for point in recent_data]

        feature_vector = [
            np.mean(so2_values),
            np.std(so2_values),
            np.min(so2_values),
            np.max(so2_values),
            np.median(so2_values),
            recent_data.last().timestamp.year,
            recent_data.last().timestamp.month,
            recent_data.last().timestamp.day,
            recent_data.last().timestamp.weekday(),
            recent_data.last().timestamp.hour,
            np.sin(2 * np.pi * recent_data.last().timestamp.month / 12),
            np.cos(2 * np.pi * recent_data.last().timestamp.month / 12),
            np.sin(2 * np.pi * recent_data.last().timestamp.day / 31),
            np.cos(2 * np.pi * recent_data.last().timestamp.day / 31),
            np.sin(2 * np.pi * recent_data.last().timestamp.hour / 24),
            np.cos(2 * np.pi * recent_data.last().timestamp.hour / 24),
        ]

        # Scale features and predict
        feature_vector_scaled = scalers[data_type].transform([feature_vector])
        prediction = models[data_type].predict(feature_vector_scaled)[0]

        return prediction

    except Exception as e:
        print(f"Error in prediction: {str(e)}")
        return None
