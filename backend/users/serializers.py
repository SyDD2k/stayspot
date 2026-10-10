from rest_framework import serializers
from .models import TestModel, Property, PropertyImage, ChatRoom, Message, RecommendedPlaceRating

class TestModelSerializer(serializers.ModelSerializer):
    class Meta:
        model = TestModel
        fields = '__all__'

class PropertyImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = PropertyImage
        fields = ['image']

class PropertySerializer(serializers.ModelSerializer):
    # Ensure the property id is always included.
    id = serializers.IntegerField(read_only=True)
    images = PropertyImageSerializer(many=True, read_only=True)
    trade_certificate = serializers.FileField(required=False)
    owner = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = Property
        fields = '__all__'

    def to_representation(self, instance):
        rep = super().to_representation(instance)
        # Always return a list for images, even if empty
        if rep.get('images') is None:
            rep['images'] = []
        return rep

class MessageSerializer(serializers.ModelSerializer):
    sender_username = serializers.CharField(source='sender.username', read_only=True)
    class Meta:
        model = Message
        fields = ['id', 'chat_room', 'sender', 'sender_username', 'content', 'timestamp']

class ChatRoomSerializer(serializers.ModelSerializer):
    user_username = serializers.CharField(source='user.username', read_only=True)
    owner_username = serializers.CharField(source='owner.username', read_only=True)
    class Meta:
        model = ChatRoom
        fields = ['id', 'property', 'user', 'owner', 'user_username', 'owner_username', 'created_at']

class RecommendedPlaceRatingSerializer(serializers.ModelSerializer):
    class Meta:
        model = RecommendedPlaceRating
        fields = ['place_name', 'rating', 'created_at']
