from django.urls import path
from .views import QuestionListCreateView, QuestionRetrieveView, AnswerCreateView, LikeQuestionView, DislikeQuestionView

urlpatterns = [
    path('questions/', QuestionListCreateView.as_view(), name='faq-question-list-create'),
    path('questions/<int:pk>/', QuestionRetrieveView.as_view(), name='faq-question-detail'),
    path('answers/', AnswerCreateView.as_view(), name='faq-answer-create'),
    path('questions/<int:pk>/like/', LikeQuestionView.as_view(), name='faq-question-like'),
    path('questions/<int:pk>/dislike/', DislikeQuestionView.as_view(), name='faq-question-dislike'),
] 