from django.urls import path, include
from django.contrib import admin

urlpatterns = [
    path('admin/', admin.site.urls),
    path('users/', include('users.urls')),  # Include the users app's routes
    path('', include('users.urls')),      # Include your app's routes
    path('faq/', include('faq.urls')),
    path('chatbot/faq/', include('chatbot_faq.urls')),
]
