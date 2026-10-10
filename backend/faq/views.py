from rest_framework import generics, permissions, filters, status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Question, Answer
from .serializers import QuestionSerializer, AnswerSerializer

class QuestionListCreateView(generics.ListCreateAPIView):
    queryset = Question.objects.all().order_by('-created_at')
    serializer_class = QuestionSerializer
    permission_classes = [permissions.AllowAny]
    filter_backends = [filters.SearchFilter]
    search_fields = ['text']

    def perform_create(self, serializer):
        serializer.save(user=None)

class QuestionRetrieveView(generics.RetrieveAPIView):
    queryset = Question.objects.all()
    serializer_class = QuestionSerializer
    permission_classes = [permissions.AllowAny]

class AnswerCreateView(generics.CreateAPIView):
    queryset = Answer.objects.all()
    serializer_class = AnswerSerializer
    permission_classes = [permissions.AllowAny]

    def perform_create(self, serializer):
        serializer.save(user=None)

class LikeQuestionView(APIView):
    permission_classes = [permissions.AllowAny]
    def post(self, request, pk):
        try:
            question = Question.objects.get(pk=pk)
            if question.likes is None:
                question.likes = 0
            question.likes += 1
            question.save()
            return Response({'likes': question.likes})
        except Question.DoesNotExist:
            return Response({'error': 'Question not found'}, status=status.HTTP_404_NOT_FOUND)

class DislikeQuestionView(APIView):
    permission_classes = [permissions.AllowAny]
    def post(self, request, pk):
        try:
            question = Question.objects.get(pk=pk)
            if question.dislikes is None:
                question.dislikes = 0
            question.dislikes += 1
            question.save()
            return Response({'dislikes': question.dislikes})
        except Question.DoesNotExist:
            return Response({'error': 'Question not found'}, status=status.HTTP_404_NOT_FOUND) 