from rest_framework import serializers
from .models import ChatbotQuestion, ChatbotAnswer

class ChatbotAnswerSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChatbotAnswer
        fields = ['id', 'question', 'text', 'created_at']

class ChatbotQuestionSerializer(serializers.ModelSerializer):
    answers = ChatbotAnswerSerializer(many=True, read_only=True)
    class Meta:
        model = ChatbotQuestion
        fields = ['id', 'text', 'created_at', 'answers'] 