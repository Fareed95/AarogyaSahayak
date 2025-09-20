from django.db import models
from authentication.models import User

class UserDeets(models.Model):
    userid = models.AutoField(primary_key=True)
    user = models.OneToOneField(User, on_delete=models.CASCADE, null=True, blank=True)  
    username = models.CharField(max_length=50)
    phoneNo = models.CharField(max_length=14, blank=True, null=True)  
    email =models.EmailField()
    # Optional fields
    # gst_number = models.CharField(max_length=15, blank=True, null=True, help_text="Optional GST Number")
    address = models.TextField(blank=True, null=True, help_text="User's address (optional)")

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    fcm_token=models.CharField(null=True,blank=True)
    def __str__(self):
        return f"{self.username} ({self.user.email})"
