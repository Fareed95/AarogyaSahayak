from rest_framework import serializers
from .models import UserDeets,Medicine,Dose

class accountSerializers(serializers.ModelSerializer):
    email = serializers.SerializerMethodField()
    is_staff = serializers.SerializerMethodField()


    class Meta:
        model = UserDeets
        fields = [
            'userid',
            'user',
            'email',
            'is_staff',
            'username',
            'phoneNo',
            'address',
            'fcm_token'
        ]



class DoseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Dose
        fields = ['dose_name', 'description', 'dose_time']

class MedicineSerializer(serializers.ModelSerializer):
    doses = DoseSerializer(many=True)
    class Meta:
        model = Medicine
        fields = ['id', 'name', 'description', 'manufacturer', 'expiry_date', 'doses']