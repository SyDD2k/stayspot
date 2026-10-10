from django.db import models
from django.contrib.auth import get_user_model
from decimal import Decimal, InvalidOperation
try:
    from bson.decimal128 import Decimal128
except ImportError:
    Decimal128 = None
User = get_user_model()

class TestModel(models.Model):
    name = models.CharField(max_length=100, default="xyz")
    password = models.CharField(max_length=100, default="123")

    def __str__(self):
        return self.name

class Property(models.Model):
    PROPERTY_TYPES = [('Room', 'Room'), ('PG/Hostel', 'PG/Hostel')]

    name = models.CharField(max_length=255)
    address = models.TextField()
    phone = models.CharField(max_length=15)
    rent = models.DecimalField(max_digits=10, decimal_places=2)
    token = models.DecimalField(max_digits=10, decimal_places=2)
    upi_id = models.CharField(max_length=100)
    property_type = models.CharField(max_length=10, choices=PROPERTY_TYPES)
    food_available = models.BooleanField(default=False)
    wifi_available = models.BooleanField(default=False)
    rooms_available = models.BooleanField(default=False)
    trade_certificate = models.FileField(upload_to='trade_certificates/', null=True, blank=True)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='properties', null=True, blank=True)

    def __str__(self):
        return self.name

    def save(self, *args, **kwargs):
        # Ensure rent is Decimal
        if Decimal128 and isinstance(self.rent, Decimal128):
            self.rent = self.rent.to_decimal()
        if isinstance(self.rent, str):
            try:
                self.rent = Decimal(self.rent)
            except InvalidOperation:
                self.rent = Decimal('0.00')
        if isinstance(self.rent, float):
            self.rent = Decimal(str(self.rent))
        # Ensure token is Decimal
        if Decimal128 and isinstance(self.token, Decimal128):
            self.token = self.token.to_decimal()
        if isinstance(self.token, str):
            try:
                self.token = Decimal(self.token)
            except InvalidOperation:
                self.token = Decimal('0.00')
        if isinstance(self.token, float):
            self.token = Decimal(str(self.token))
        super().save(*args, **kwargs)

class PropertyImage(models.Model):
    property = models.ForeignKey(Property, related_name='images', on_delete=models.CASCADE)
    image = models.ImageField(upload_to='property_images/')
 



    def __str__(self):
        return f"Image for {self.property.name}"

class ChatRoom(models.Model):
    property = models.ForeignKey(Property, on_delete=models.CASCADE, related_name='chat_rooms')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='chat_rooms')  # The user who chats with the owner
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='owned_chat_rooms')  # The property owner
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"ChatRoom for {self.property.name} ({self.user.username} <-> {self.owner.username})"

class Message(models.Model):
    chat_room = models.ForeignKey(ChatRoom, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages')
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Message from {self.sender.username} at {self.timestamp}"

class RecommendedPlaceRating(models.Model):
    place_name = models.CharField(max_length=255)
    rating = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Rating for {self.place_name}: {self.rating}"
