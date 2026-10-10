from rest_framework import serializers
from .models import Question, Answer

class AnswerSerializer(serializers.ModelSerializer):
    user = serializers.StringRelatedField(read_only=True)
    class Meta:
        model = Answer
        fields = ['id', 'question', 'text', 'user', 'created_at']

class QuestionSerializer(serializers.ModelSerializer):
    user = serializers.StringRelatedField(read_only=True)
    answers = AnswerSerializer(many=True, read_only=True)
    class Meta:
        model = Question
        fields = ['id', 'text', 'user', 'created_at', 'status', 'likes', 'dislikes', 'answers'] 