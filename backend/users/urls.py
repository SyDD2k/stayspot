from django.urls import path, include, re_path
from rest_framework.routers import DefaultRouter
from django.views.generic.base import RedirectView
from django.conf import settings
from django.conf.urls.static import static
from .views import get_testmodels, create_testmodel, PropertyViewSet, geocode, geolocation, place_details, nearby_search, text_search, place_photo, find_place_from_text, autocomplete, firebase_config, get_or_create_chat_room, get_messages, send_message, owner_chat_rooms, submit_rating, get_ratings

router = DefaultRouter()
router.register(r'properties', PropertyViewSet)

urlpatterns = [
    path('api/testmodels/', get_testmodels, name="get-testmodels"),
    path('api/testmodels/create/', create_testmodel, name="create-testmodel"),
    # Redirect double slash in properties URL to the correct URL
    re_path(r'^properties//$', RedirectView.as_view(url='/properties/', permanent=True)),
    path('', include(router.urls)),  # Exposes /properties/ at the root
    path('api/geocode/', geocode, name="geocode"),
    path('api/geolocation/', geolocation, name="geolocation"),
    path('api/place_details/', place_details, name="place-details"),
    path('api/nearby_search/', nearby_search, name="nearby-search"),
    path('api/text_search/', text_search, name="text-search"),
    path('api/place_photo/', place_photo, name="place-photo"),
    path('api/find_place_from_text/', find_place_from_text, name="find-place-from-text"),
    path('api/autocomplete/', autocomplete, name="autocomplete"),
    path('api/firebase_config/', firebase_config, name="firebase-config"),
    path('api/chat/get_or_create/', get_or_create_chat_room, name="get-or-create-chat-room"),
    path('api/chat/<int:chat_room_id>/messages/', get_messages, name="get-messages"),
    path('api/chat/send_message/', send_message, name="send-message"),
    path('api/owner/chat_rooms/', owner_chat_rooms, name="owner-chat-rooms"),
    path('api/ratings/submit/', submit_rating, name="submit-rating"),
    path('api/ratings/get/', get_ratings, name="get-ratings"),
]+ static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
