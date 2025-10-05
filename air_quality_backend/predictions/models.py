from django.db import models

class PredictionResult(models.Model):
    data_type = models.CharField(max_length=20, choices=[('ground', 'Ground Sensor'), ('satellite', 'Satellite')])
    prediction_value = models.FloatField()
    confidence = models.FloatField()
    model_name = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.data_type} - {self.prediction_value:.4f}"

class DataPoint(models.Model):
    data_type = models.CharField(max_length=20, choices=[('ground', 'Ground Sensor'), ('satellite', 'Satellite')])
    so2_value = models.FloatField()
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    timestamp = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-timestamp']
    
    def __str__(self):
        return f"{self.data_type} - {self.so2_value:.4f} at {self.timestamp}"