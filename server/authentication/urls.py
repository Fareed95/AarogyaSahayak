from django.urls import path, include
from rest_framework import routers
from .views import RegisterView,ResendotpView,LoginView,LogoutView,PasswordResetRequestView,UserView,PasswordResetView
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
from django.conf import settings
from django.conf.urls.static import static
urlpatterns = [
    path('register/',RegisterView.as_view()),
    path('resendotp/',ResendotpView.as_view()),
    path('login/',LoginView.as_view()),
    path('user/',UserView.as_view()),
    path('logout/',LogoutView.as_view()),
    path('password-reset-request/', PasswordResetRequestView.as_view(), name='password-reset-request'),
    path('password-reset/', PasswordResetView.as_view(), name='password-reset'),

]+ static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)



urlpatterns  += staticfiles_urlpatterns()