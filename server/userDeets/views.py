from django.shortcuts import render
import logging
logger = logging.getLogger(__name__)
# Create your views here.
# Create your views here.
from django.http import HttpResponse
from rest_framework.views import APIView
from .serializers import accountSerializers
from .models import UserDeets
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework.exceptions import AuthenticationFailed
import jwt
from rest_framework import status
import requests
from google.oauth2 import service_account
from google.auth.transport.requests import Request
class UserDeetsViewSet(APIView):
        def get(self,request):
            token = request.headers.get('Authorization')

            if not token:
                raise AuthenticationFailed('Unauthenticated!')

            try:
                
                payload = jwt.decode(token, 'secret', algorithms="HS256")
            except jwt.ExpiredSignatureError:
                raise AuthenticationFailed('Token expired!')
            except jwt.InvalidTokenError:
                raise AuthenticationFailed('Invalid token!')

            user = UserDeets.objects.filter(email=payload['email']).first()    
            serializer = accountSerializers(user)

            return Response(serializer.data)

        def patch(self,request):
            token = request.headers.get('Authorization')

            if not token:
                raise AuthenticationFailed('Unauthenticated!')

            try:
                payload = jwt.decode(token, 'secret', algorithms="HS256")
            except jwt.ExpiredSignatureError:
                raise AuthenticationFailed('Token expired!')
            except jwt.InvalidTokenError:
                raise AuthenticationFailed('Invalid token!')

            user = UserDeets.objects.filter(email=payload['email']).first() 
            fcm_token=request.data.get('fcm_token')
            address=request.data.get('address')
            # gst_number=request.data.get('gst_number')
            phoneNo=request.data.get('phoneNo')
            username=request.data.get('username')
            if fcm_token is not None:
                user.fcm_token=fcm_token
            if address is not None:
                user.address=address
            # if gst_number is not None:
            #     user.gst_number=gst_number
            if phoneNo is not None:
                user.phoneNo=phoneNo
            if username is not None:
                user.username=username
            user.save()
            return Response({"message": "User info updated successfully !"}, status=status.HTTP_201_CREATED)


SERVICE_ACCOUNT_FILE = 'userDeets/hackathon-996b5-firebase-adminsdk-fbsvc-8fd9d7f423.json'
SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']

def get_access_token():
    credentials = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE, scopes=SCOPES
    )
    credentials.refresh(Request())
    return credentials.token

# Example usage


class NotificationViewset(APIView):
    
    def post(self, request):
        title = request.data.get('title', 'Notification')
        body = request.data.get('body', '')

        # 1. Get all FCM tokens (non-null and non-empty)
        tokens = list(
            UserDeets.objects.filter(fcm_token__isnull=False)
                             .exclude(fcm_token="")
                             .values_list('fcm_token', flat=True)
        )

        if not tokens:
            return Response({"message": "No users with FCM token found."},
                            status=status.HTTP_400_BAD_REQUEST)
        print(tokens)
        # 2. Get OAuth2 access token
        token = get_access_token()
        print(token)
        # 3. FCM HTTP v1 API endpoint
        url = "https://fcm.googleapis.com/v1/projects/hackathon-996b5/messages:send"

        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json; UTF-8"
        }

        # 4. Payload: for multiple devices, must send one message per token in v1 API
        results = []
        for fcm_token in tokens:
            payload = {
                "message": {
                    "token": fcm_token,
                    "notification": {"title": title, "body": body},
                    "data": {
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                        "id": "1",
                        "status": "done"
                    }
                }
            }

            try:
                response = requests.post(url, headers=headers, json=payload)
                try:
                    results.append(response.json())
                except requests.JSONDecodeError:
                    results.append({
                        "error": "Invalid JSON",
                        "status_code": response.status_code,
                        "text": response.text
                    })
            except Exception as e:
                results.append({"error": str(e)})

        return Response({
            "message": "Notification sent",
            "fcm_responses": results
        }, status=status.HTTP_200_OK)
def a(request):
    return HttpResponse("supp")
    