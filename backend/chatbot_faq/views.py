from rest_framework import generics, filters, permissions
from .models import ChatbotQuestion, ChatbotAnswer
from .serializers import ChatbotQuestionSerializer, ChatbotAnswerSerializer

class ChatbotQuestionListCreateView(generics.ListCreateAPIView):
    queryset = ChatbotQuestion.objects.all().order_by('-created_at')
    serializer_class = ChatbotQuestionSerializer
    permission_classes = [permissions.AllowAny]
    filter_backends = [filters.SearchFilter]
    search_fields = ['text']

class ChatbotQuestionRetrieveView(generics.RetrieveAPIView):
    queryset = ChatbotQuestion.objects.all()
    serializer_class = ChatbotQuestionSerializer
    permission_classes = [permissions.AllowAny]

class ChatbotAnswerCreateView(generics.CreateAPIView):
    queryset = ChatbotAnswer.objects.all()
    serializer_class = ChatbotAnswerSerializer
    permission_classes = [permissions.AllowAny] 