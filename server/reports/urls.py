from django.urls import path
from .views import UploadReportView, UserChatBotAPIView

urlpatterns = [
    path('report/', UploadReportView.as_view()),  
    path('chatbot/', UserChatBotAPIView.as_view()),

]