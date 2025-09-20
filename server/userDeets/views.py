from django.http import HttpResponse
from rest_framework.views import APIView
from .serializers import accountSerializers,MedicineSerializer
from .models import UserDeets,Medicine,Dose
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework.exceptions import AuthenticationFailed
import jwt
from django.utils.dateparse import parse_date
from rest_framework import status
import requests
from google.oauth2 import service_account
from google.auth.transport.requests import Request
from utils.usercheck import authenticate_request
class UserDeetsViewSet(APIView):
    def get(self,request):
            user = authenticate_request(request, need_user=True)
            userdetails = UserDeets.objects.filter(userid=user.id).first()    
            try:
                print("inside try")
                serializer = accountSerializers(userdetails)
                print(serializer.data)
            except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

            return Response(serializer.data)

    def patch(self,request):
            user = authenticate_request(request, need_user=True)
            userdetails = UserDeets.objects.filter(userid=user.id).first()   
            fcm_token=request.data.get('fcm_token')
            address=request.data.get('address')
            gst_number=request.data.get('gst_number')
            phoneNo=request.data.get('phoneNo')
            username=request.data.get('username')
            if fcm_token is not None:
                userdetails.fcm_token=fcm_token
            if address is not None:
                userdetails.address=address
            if gst_number is not None:
                userdetails.gst_number=gst_number
            if phoneNo is not None:
                userdetails.phoneNo=phoneNo
            if username is not None:
                userdetails.username=username
            userdetails.save()
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
    




class getMedicineViewset(APIView):
    def post(self, request):
        patient_token = request.data.get('patient_token')
        if not patient_token:
            raise AuthenticationFailed('Token not given!')

        
        user_deets = UserDeets.objects.filter(email=patient_token).first()
        if not user_deets:
            raise AuthenticationFailed('Invalid token: user not found!')

        
        medicines = Medicine.objects.filter(user=user_deets.user).prefetch_related('doses')

        
        serializer = MedicineSerializer(medicines, many=True)
        return Response({
            "patient": user_deets.username,
            "medicines": serializer.data
        })
    


class PostMedicineView(APIView):
    def post(self, request):
        patient_token = request.data.get('patient_token')
        if not patient_token:
            raise AuthenticationFailed('Token not given!')

        user_deets = UserDeets.objects.filter(email=patient_token).first()
        if not user_deets:
            raise AuthenticationFailed('Invalid token: user not found!')

        # pull nested doses from data
        doses_data = request.data.pop('doses', [])

        # create medicine
        medicine = Medicine.objects.create(
            user=user_deets.user,
            name=request.data.get('name'),
            description=request.data.get('description'),
            manufacturer=request.data.get('manufacturer'),
            expiry_date=parse_date(request.data.get('expiry_date'))
        )

        # create each dose
        for d in doses_data:
            Dose.objects.create(
                medicine=medicine,
                dose_name=d.get('dose_name'),
                description=d.get('description'),
                dose_time=d.get('dose_time')
            )

        # serialize for response
        serializer = MedicineSerializer(medicine)
        return Response(serializer.data, status=201)




    def patch(self, request, pk):
        
        patient_token = request.data.get('patient_token')
        if not patient_token:
            raise AuthenticationFailed('Token not given!')

        user_deets = UserDeets.objects.filter(email=patient_token).first()
        if not user_deets:
            raise AuthenticationFailed('Invalid token: user not found!')


        try:
            medicine = Medicine.objects.get(id=pk, user=user_deets.user)
        except Medicine.DoesNotExist:
            raise AuthenticationFailed('Medicine not found or not allowed!')


        doses_data = request.data.pop('doses', None)


        if 'name' in request.data:
            medicine.name = request.data['name']
        if 'description' in request.data:
            medicine.description = request.data['description']
        if 'manufacturer' in request.data:
            medicine.manufacturer = request.data['manufacturer']
        if 'expiry_date' in request.data:
            medicine.expiry_date = parse_date(request.data['expiry_date'])
        medicine.save()

        # If client sent doses, replace old doses with new ones
        if doses_data is not None:
            medicine.doses.all().delete()
            for d in doses_data:
                Dose.objects.create(
                    medicine=medicine,
                    dose_name=d.get('dose_name'),
                    description=d.get('description'),
                    dose_time=d.get('dose_time')
                )


        serializer = MedicineSerializer(medicine)
        return Response(serializer.data)
