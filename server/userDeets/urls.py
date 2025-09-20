from django.urls import path
from .views import UserDeetsViewSet, a,NotificationViewset

urlpatterns = [
    path('user/', UserDeetsViewSet.as_view()),  
    path('notification/', NotificationViewset.as_view()),  
   
]
