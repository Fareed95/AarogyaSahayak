

from rest_framework import serializers
# from asuka_server.models import items
from .models import User
from django.utils import timezone

class userSerializers(serializers.ModelSerializer):
    confirm_password = serializers.CharField(write_only=True)
    otp = serializers.CharField(required=True,write_only=True)
    class Meta:
        model = User
        fields =[
            'id',
            'name',
            'email',
            'password',
            'confirm_password',
            'otp',
            'is_staff',
            'phone_number'
        ]
        extra_kwargs={
            'password':{'write_only':True}
        }
class passwordResetReqSerializers(serializers.Serializer):
    email= serializers.EmailField()

class passwordResetSerializers(serializers.Serializer):
    email= serializers.EmailField()
    otp = serializers.CharField(max_length=6)
    new_password=serializers.CharField(write_only=True)

