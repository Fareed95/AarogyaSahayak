

from rest_framework import serializers
# from asuka_server.models import items
from .models import UserDeets

class accountSerializers(serializers.ModelSerializer):
    email = serializers.EmailField(source='user.email',read_only=True)
    is_staff = serializers.EmailField(source='user.is_staff',read_only=True)
    class Meta:
        model = UserDeets
        fields = [
            'userid',
            'user',
            'email',
            'is_staff',
            'username',
            'phoneNo',
            # 'gst_number',
            'address',
            'fcm_token'
        ]


# class projSerializers(serializers.ModelSerializer):
#     class Meta:
#         model = projectsmodels
#         fields = '__all__'