from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework import viewsets, status
from rest_framework.parsers import MultiPartParser, FormParser
from .models import TestModel, Property, PropertyImage, ChatRoom, Message, RecommendedPlaceRating
from .serializers import TestModelSerializer, PropertySerializer, MessageSerializer, ChatRoomSerializer, RecommendedPlaceRatingSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import get_user_model, authenticate
from rest_framework.permissions import AllowAny, IsAuthenticated
from django.core.validators import validate_email
from django.core.exceptions import ValidationError
from django.contrib.auth.password_validation import validate_password
from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt
import requests

User = get_user_model()
GO_MAPS_API_KEY = 'AlzaSym7b02mLbqyAJtBgDjj4J5JCzPh_ezMThr'

@api_view(['GET'])
def get_testmodels(request):
    testmodels = TestModel.objects.all()
    serializer = TestModelSerializer(testmodels, many=True)
    return Response(serializer.data)

@api_view(['POST'])
def create_testmodel(request):
    serializer = TestModelSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=201)
    return Response(serializer.errors, status=400)

class PropertyViewSet(viewsets.ModelViewSet):
    queryset = Property.objects.all()
    serializer_class = PropertySerializer
    parser_classes = (MultiPartParser, FormParser)

    def create(self, request, *args, **kwargs):
        data = request.data.copy()
        images = request.FILES.getlist('images')
        data['owner'] = request.user.id if request.user.is_authenticated else None
        serializer = PropertySerializer(data=data)
        if serializer.is_valid():
            property_instance = serializer.save(owner=request.user if request.user.is_authenticated else None)
            for img in images:
                PropertyImage.objects.create(property=property_instance, image=img)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@csrf_exempt
def geocode(request):
    address = request.GET.get('address')
    if not address:
        return JsonResponse({'error': 'Address parameter is required'}, status=400)
    url = f"https://maps.gomaps.pro/maps/api/geocode/json?address={address}&key={GO_MAPS_API_KEY}"
    response = requests.get(url)
    return JsonResponse(response.json(), safe=False)

@csrf_exempt
def geolocation(request):
    url = f"https://www.gomaps.pro/geolocation/v1/geolocate?key={GO_MAPS_API_KEY}"
    response = requests.post(url)
    return JsonResponse(response.json(), safe=False)

@csrf_exempt
def place_details(request):
    place_id = request.GET.get('place_id')
    if not place_id:
        return JsonResponse({'error': 'Place ID is required'}, status=400)
    url = f"https://maps.gomaps.pro/maps/api/place/details/json?place_id={place_id}&key={GO_MAPS_API_KEY}"
    response = requests.get(url)
    return JsonResponse(response.json(), safe=False)

@csrf_exempt
def nearby_search(request):
    location = request.GET.get('location')
    name = request.GET.get('name')
    if not location:
        return JsonResponse({'error': 'Location parameter is required'}, status=400)
    url = f"https://maps.gomaps.pro/maps/api/place/nearbysearch/json?location={location}&name={name}&key={GO_MAPS_API_KEY}"
    response = requests.get(url)
    return JsonResponse(response.json(), safe=False)

@csrf_exempt
def text_search(request):
    query = request.GET.get('query')
    if not query:
        return JsonResponse({'error': 'Query parameter is required'}, status=400)
    url = f"https://maps.gomaps.pro/maps/api/place/textsearch/json?query={query}&key={GO_MAPS_API_KEY}"
    response = requests.get(url)
    return JsonResponse(response.json(), safe=False)

@csrf_exempt
def place_photo(request):
    photo_reference = request.GET.get('photo_reference')
    if not photo_reference:
        return JsonResponse({'error': 'photo_reference is required'}, status=400)
    url = f"https://maps.gomaps.pro/maps/api/place/photo?photo_reference={photo_reference}&maxwidth=400&key={GO_MAPS_API_KEY}"
    response = requests.get(url)
    if response.status_code == 200:
        return HttpResponse(response.content, content_type="image/jpeg")
    else:
        return JsonResponse({"error": "Failed to fetch photo"}, status=500)

@csrf_exempt
def find_place_from_text(request):
    input_text = request.GET.get('input')
    input_type = request.GET.get('inputtype', 'textquery')
    if not input_text:
        return JsonResponse({'error': 'Input parameter is required'}, status=400)
    url = f"https://maps.gomaps.pro/maps/api/place/findplacefromtext/json?input={input_text}&inputtype={input_type}&key={GO_MAPS_API_KEY}"
    response = requests.get(url)
    return JsonResponse(response.json(), safe=False)

@csrf_exempt
def autocomplete(request):
    input_text = request.GET.get('input', '')
    if not input_text:
        return JsonResponse({'error': 'Input parameter is required'}, status=400)
    url = f"https://maps.gomaps.pro/maps/api/place/autocomplete/json?input={input_text}&key={GO_MAPS_API_KEY}"
    response = requests.get(url)
    if response.status_code == 200:
        return JsonResponse(response.json(), safe=False)
    else:
        return JsonResponse({"error": "Failed to fetch data from autocomplete API"}, status=500)

@csrf_exempt
def firebase_config(request):
    config = {
        "apiKey": "AIzaSyAXgu_bmYX2AFvpd50KPfo35ZBj1aORmSY",
        "authDomain": "stays-2d46b.firebaseapp.com",
        "projectId": "stays-2d46b",
        "storageBucket": "stays-2d46b.firebasestorage.app",
        "messagingSenderId": "895472709439",
        "appId": "1:895472709439:web:d60ba5c10bc727fd156d8a",
        "measurementId": "G-0929BZ390B"
    }
    return JsonResponse(config)

@api_view(['POST'])
def get_or_create_chat_room(request):
    user = request.user if request.user.is_authenticated else None
    property_id = request.data.get('property_id')
    try:
        property_obj = Property.objects.get(id=property_id)
    except Property.DoesNotExist:
        return Response({'error': 'Property not found'}, status=404)
    owner = property_obj.owner if hasattr(property_obj, 'owner') else None
    if not owner:
        # Fallback: assign the first user as owner if missing
        User = get_user_model()
        owner = User.objects.first()
        property_obj.owner = owner
        property_obj.save()
    chat_room, created = ChatRoom.objects.get_or_create(property=property_obj, user=user, owner=owner)
    serializer = ChatRoomSerializer(chat_room)
    return Response(serializer.data)

@api_view(['GET'])
def get_messages(request, chat_room_id):
    try:
        chat_room = ChatRoom.objects.get(id=chat_room_id)
    except ChatRoom.DoesNotExist:
        return Response({'error': 'Chat room not found'}, status=404)
    messages = chat_room.messages.order_by('timestamp')
    serializer = MessageSerializer(messages, many=True)
    return Response(serializer.data)

@api_view(['POST'])
def send_message(request):
    user = request.user if request.user.is_authenticated else None
    chat_room_id = request.data.get('chat_room_id')
    content = request.data.get('content')
    try:
        chat_room = ChatRoom.objects.get(id=chat_room_id)
    except ChatRoom.DoesNotExist:
        return Response({'error': 'Chat room not found'}, status=404)
    message = Message.objects.create(chat_room=chat_room, sender=user, content=content)
    serializer = MessageSerializer(message)
    return Response(serializer.data, status=201)

@api_view(['GET'])
def owner_chat_rooms(request):
    chat_rooms = ChatRoom.objects.all().order_by('-created_at')  # For testing: show all chat rooms
    serializer = ChatRoomSerializer(chat_rooms, many=True)
    return Response(serializer.data)

@api_view(['POST'])
def submit_rating(request):
    serializer = RecommendedPlaceRatingSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
def get_ratings(request):
    place_name = request.query_params.get('place_name')
    if not place_name:
        return Response({'error': 'Place name is required'}, status=status.HTTP_400_BAD_REQUEST)
    ratings = RecommendedPlaceRating.objects.filter(place_name=place_name)
    serializer = RecommendedPlaceRatingSerializer(ratings, many=True)
    return Response(serializer.data)
    

