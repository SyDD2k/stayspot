from django.db import models

class ChatbotQuestion(models.Model):
    text = models.TextField(unique=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.text[:50]

class ChatbotAnswer(models.Model):
    question = models.ForeignKey(ChatbotQuestion, on_delete=models.CASCADE, related_name='answers')
    text = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.text[:50] 