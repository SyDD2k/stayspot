from django.urls import path
from .views import ChatbotQuestionListCreateView, ChatbotQuestionRetrieveView, ChatbotAnswerCreateView

urlpatterns = [
    path('questions/', ChatbotQuestionListCreateView.as_view(), name='chatbot-question-list-create'),
    path('questions/<int:pk>/', ChatbotQuestionRetrieveView.as_view(), name='chatbot-question-detail'),
    path('answers/', ChatbotAnswerCreateView.as_view(), name='chatbot-answer-create'),
] 