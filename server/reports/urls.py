from django.urls import path
from .views import UploadReportView

urlpatterns = [
    path('report/', UploadReportView.as_view()),  
]