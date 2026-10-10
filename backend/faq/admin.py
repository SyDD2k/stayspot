from django.contrib import admin
from .models import Question, Answer

@admin.register(Question)
class QuestionAdmin(admin.ModelAdmin):
    list_display = ('text', 'status', 'created_at')
    list_filter = ('status', 'created_at')
    search_fields = ('text',)

@admin.register(Answer)
class AnswerAdmin(admin.ModelAdmin):
    list_display = ('text', 'question', 'created_at')
    search_fields = ('text',) 