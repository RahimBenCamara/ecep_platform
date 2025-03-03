from rest_framework import serializers
from .models import User, Matiere, Cours, Ressource, Examen, QuestionQCM, SoumissionExamen, Badge, AttributionBadge, Paiement, Message

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'role', 'is_active', 'fcm_token', 'parent']

class MatiereSerializer(serializers.ModelSerializer):
    class Meta:
        model = Matiere
        fields = '__all__'

class RessourceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ressource
        fields = '__all__'

class CoursSerializer(serializers.ModelSerializer):
    ressources = RessourceSerializer(many=True, read_only=True)
    class Meta:
        model = Cours
        fields = '__all__'

class QuestionQCMSerializer(serializers.ModelSerializer):
    class Meta:
        model = QuestionQCM
        fields = '__all__'

class ExamenSerializer(serializers.ModelSerializer):
    questions = QuestionQCMSerializer(many=True, read_only=True)
    class Meta:
        model = Examen
        fields = '__all__'

class SoumissionExamenSerializer(serializers.ModelSerializer):
    class Meta:
        model = SoumissionExamen
        fields = '__all__'

class BadgeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Badge
        fields = '__all__'

class AttributionBadgeSerializer(serializers.ModelSerializer):
    badge = BadgeSerializer()
    class Meta:
        model = AttributionBadge
        fields = ['id', 'user', 'badge', 'date_obtention']

class PaiementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Paiement
        fields = '__all__'

class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = '__all__'