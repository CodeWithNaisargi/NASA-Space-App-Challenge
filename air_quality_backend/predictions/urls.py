from django.urls import path
from . import views

urlpatterns = [
    path('predictions/', views.get_predictions, name='get_predictions'),
    path('predict-custom/', views.predict_custom, name='predict_custom'),
    path('data-points/', views.get_data_points, name='get_data_points'),
    path('model-info/', views.get_model_info, name='get_model_info'),
]
