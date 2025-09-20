from .models import User
from .serializers import userSerializers, passwordResetReqSerializers,passwordResetSerializers
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
import jwt
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from django.utils.crypto import get_random_string
import datetime
from django.utils import timezone
from rest_framework.exceptions import AuthenticationFailed
from django.views.decorators.csrf import csrf_exempt
from rest_framework.permissions import AllowAny
from userDeets.models import UserDeets
class RegisterView(APIView):
    @csrf_exempt
    def post(self,request):
        email=request.data.get('email')
        username=request.data.get('username')
        password=request.data.get('password')

        if not email or not username or not password:
            return Response({'message':'Please send all fields!'},status=status.HTTP_400_BAD_REQUEST)
        existingUser = User.objects.filter(email=email).first()
        if existingUser and existingUser.is_active:
            return Response({'message':'user already exists !'},status=status.HTTP_400_BAD_REQUEST)
        otp = get_random_string(length=6,allowed_chars='0123456789')

        if existingUser:
            existingUser.email=email
            existingUser.set_password(password)
            existingUser.otp=otp
            existingUser.username=username
            existingUser.otp_expiration=timezone.now()+timezone.timedelta(minutes=5)
            existingUser.is_active=False
            existingUser.save()
            user = existingUser

        else:
            user=User.objects.create_user(email=email,password=password,name=username)
            user.otp=otp
            user.otp_expiration = timezone.now() + timezone.timedelta(minutes=5)
            user.is_active = False
            user.save()

        html_message = render_to_string('email/register_otp.html', {'otp': otp})
        send_mail(
            'Your OTP Code',
            f'Your OTP code is {otp}',
            'teamasuka@gmail.com',
            [email],
            fail_silently=False,
            html_message=html_message,
        )
        return Response({"message": "User created successfully. OTP sent to your email."}, status=status.HTTP_201_CREATED)

    def put(self, request):
        email = request.data.get('email')
        otp = request.data.get('otp')
        user = User.objects.filter(email=email).first()

        if user and user.otp == otp and user.otp_expiration > timezone.now():
            user.is_active = True
            user.otp = None
            user.otp_expiration = None
            user.save()
           
            html_message = render_to_string('email/welcome.html', {'name': user.name})
            send_mail(
                'Welcome to Asuka',
                'Thank you for verifying your email.',
                'teamasuka@gmail.com',  # Replace with your email
                [email],
                fail_silently=False,
                html_message=html_message,
            )
            UserDeets.objects.update_or_create(
                user=user,
                username=user.name,
                email=email
                        )
            user = User.objects.filter(email=email).first()
            if user is None:
                raise AuthenticationFailed('user not found')
            
            payload ={
                'email':user.email,
                'exp': datetime.datetime.utcnow() + datetime.timedelta(days=7),
                'iat': datetime.datetime.utcnow()
            }
            token = jwt.encode(payload, 'secret', algorithm='HS256')

            response = Response()
            response.data = {
                'jwt': token  ,
                'message': 'User verified successfully'
            }

            return response
            
        else:
            return Response({'error': 'Invalid OTP or OTP expired'}, status=status.HTTP_400_BAD_REQUEST)
        

class ResendotpView(APIView):
    @csrf_exempt
    def post(self, request):
        email = request.data.get('email')
        user = User.objects.filter(email=email).first()

        if user:
            otp = get_random_string(length=6, allowed_chars='0123456789')
            user.otp = otp
            user.otp_expiration = timezone.now() + timezone.timedelta(minutes=5)
            user.save()
            html_message = render_to_string('email/otp_resend.html', {'otp': otp})
            send_mail(
                'Your OTP Code',
                f'Your OTP code is {otp}',
                'teamasuka@gmail.com',
                [email],
                fail_silently=False,
                html_message=html_message,
            )
            return Response({"message": "OTP resent successfully."}, status=status.HTTP_200_OK)
        else:
            return Response({"error": "User with this email does not exist."}, status=status.HTTP_400_BAD_REQUEST)
        


class LoginView (APIView):
    @csrf_exempt
    def post(self,request):
        email = request.data['email']
        password = request.data['password']

        user = User.objects.filter(email=email).first()
        if user is None:
            raise AuthenticationFailed('user not found')
        if not user.check_password(password):
            raise AuthenticationFailed('Wrong password')
        if not user.is_active:
            raise AuthenticationFailed("not verified")
        payload ={
            'email':user.email,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(days=7),
            'iat': datetime.datetime.utcnow()
        }
        token = jwt.encode(payload, 'secret', algorithm='HS256')

        response = Response()
        response.data = {
            'jwt': token  
        }

        return response
    

class LogoutView(APIView):
    @csrf_exempt
    def post(self, request):
       

        response = Response()
        response.delete_cookie('jwt')
        response.data = {
            'message': "Logged out successfully"
        }
        return response


class PasswordResetRequestView(APIView):
    def post(self, request):
        email = request.data.get('email')
        if not email:
            return Response({"message": "Email is required."},
                            status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.filter(email=email).first()
        if not user:   
            return Response({"message": "User with this email does not exist."},
                            status=status.HTTP_400_BAD_REQUEST)

        otp = get_random_string(length=6, allowed_chars='0123456789')
        user.otp = otp
        user.otp_expiration = timezone.now() + timezone.timedelta(minutes=5)
        user.save()

        html_message = render_to_string('email/password_reset.html', {'otp': otp})

        send_mail(
            'Password Reset OTP',
            f'Your OTP for password reset is {otp}.',
            'teamasuka@gmail.com',
            [email],
            fail_silently=False,
            html_message=html_message,
        )

        return Response({"message": "OTP sent to your email."},
                        status=status.HTTP_200_OK)


class PasswordResetView(APIView):
    def post(self, request):
        email = request.data.get('email')
        otp = request.data.get('otp')
        new_password = request.data.get('new_password')

        if not all([email, otp, new_password]):
            return Response({"message": "Email, OTP and new password are required."},
                            status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.filter(email=email).first()
        if not user:
            return Response({"message": "User with this email does not exist."},
                            status=status.HTTP_400_BAD_REQUEST)

        if user.otp != otp or user.otp_expiration < timezone.now():
            return Response({"message": "Invalid OTP or OTP expired."},
                            status=status.HTTP_400_BAD_REQUEST)

        user.set_password(new_password)
        user.save()

        html_message = render_to_string('email/password_reset_sucessful.html',
                                        {'name': user.name})
        send_mail(
            'Password Reset Successful',
            'Your password has been reset successfully.',
            'teamasuka@gmail.com',
            [email],
            fail_silently=False,
            html_message=html_message,
        )
        return Response({"message": "Password reset successful."},
                        status=status.HTTP_200_OK)



class UserView(APIView):
    @csrf_exempt
    def get(self, request):

        token = request.headers.get('Authorization')
        if not token:
            raise AuthenticationFailed('Unauthenticated!')

        try:
            payload = jwt.decode(token, 'secret', algorithms="HS256")
        except jwt.ExpiredSignatureError:
            raise AuthenticationFailed('Token expired!')
        except jwt.InvalidTokenError:
            raise AuthenticationFailed('Invalid token!')

        user = User.objects.filter(email=payload['email']).first()
        serializer = userSerializers(user)

        return Response(serializer.data)

    @csrf_exempt
    def patch(self, request):
        token = request.headers.get('Authorization')

        if not token:
            raise AuthenticationFailed('Unauthenticated!')

        try:
            payload = jwt.decode(token, 'secret', algorithms="HS256")
        except jwt.ExpiredSignatureError:
            raise AuthenticationFailed('Token expired!')
        except jwt.InvalidTokenError:
            raise AuthenticationFailed('Invalid token!')

        user = User.objects.filter(id=payload['id']).first()
        if not user:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

        data = request.data
        if "name" in data:
            user.name = data["name"]
        else:
            return Response({"error": "You can only update your name"}, status=status.HTTP_403_FORBIDDEN)

        user.save()
        html_message = render_to_string('email/name_reset_sucessful.html', {'name': user.name})
        send_mail(
                'Name Reset Successful',
                'Your name has been reset successfully.',
                'teamasuka@gmail.com',
                [user.email],
                fail_silently=False,
                html_message=html_message,
            )
        return Response({"message":f"Your name is updated successfully to {user.name}"}, status=status.HTTP_200_OK)

        
    @csrf_exempt
    def delete(self, request):
        token = request.headers.get('Authorization')
       


        if not token:
            raise AuthenticationFailed('Unauthenticated!')

        try:
            payload = jwt.decode(token, 'secret', algorithms="HS256")
        except jwt.ExpiredSignatureError:
            raise AuthenticationFailed('Token expired!')
        except jwt.InvalidTokenError:
            raise AuthenticationFailed('Invalid token!')

        user = User.objects.filter(id=payload['id']).first()
        if not user:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

        # User can delete only their own account
        user.delete()
        html_message = render_to_string('email/account_deleted_sucessful.html', {'name': user.name})
        send_mail(
                'Account Deleted Successful',
                'Your account has been permanently deleted successfully.',
                'teamasuka@gmail.com',
                [user.email],
                fail_silently=False,
                html_message=html_message,
            )
        return Response({"message": "Your account has been deleted successfully"}, status=status.HTTP_200_OK)