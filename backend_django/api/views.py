from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from firebase_admin import messaging
import requests
from api import models
from .models import User, Matiere, Cours, Ressource, Examen, QuestionQCM, SoumissionExamen, Badge, AttributionBadge, Paiement, Message
from .serializers import (UserSerializer, MatiereSerializer, CoursSerializer, RessourceSerializer,
                         ExamenSerializer, QuestionQCMSerializer, SoumissionExamenSerializer,
                         BadgeSerializer, AttributionBadgeSerializer, PaiementSerializer, MessageSerializer)


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_permissions(self):
        if self.action in ['create']:
            return [permissions.AllowAny()]
        return [permissions.IsAuthenticated()]

    @action(detail=False, methods=['get'], url_path='enfants')
    def get_enfants(self, request):
        if request.user.role != 'PARENT':
            return Response({"detail": "Non autorisé"}, status=status.HTTP_403_FORBIDDEN)
        enfants = User.objects.filter(parent=request.user)
        serializer = UserSerializer(enfants, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['patch'], url_path='update-fcm')
    def update_fcm(self, request, pk=None):
        user = self.get_object()
        user.fcm_token = request.data.get('fcm_token')
        user.save()
        return Response({"message": "Token FCM mis à jour"}, status=status.HTTP_200_OK)

class MatiereViewSet(viewsets.ModelViewSet):
    queryset = Matiere.objects.all()
    serializer_class = MatiereSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_permissions(self):
        if self.request.method in ['POST', 'PUT', 'DELETE']:
            return [permissions.IsAdminUser()]
        return [permissions.IsAuthenticated()]

class CoursViewSet(viewsets.ModelViewSet):
    queryset = Cours.objects.all()
    serializer_class = CoursSerializer

    def get_permissions(self):
        if self.request.method in ['POST', 'PUT', 'DELETE']:
            return [permissions.IsAuthenticated(), permissions.DjangoModelPermissions()]
        return [permissions.IsAuthenticated()]

    def perform_create(self, serializer):
        serializer.save(enseignant=self.request.user)

    @action(detail=True, methods=['post'])
    def upload_ressource(self, request, pk=None):
        cours = self.get_object()
        serializer = RessourceSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(cours=cours)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ExamenViewSet(viewsets.ModelViewSet):
    queryset = Examen.objects.all()
    serializer_class = ExamenSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(cours=Cours.objects.get(id=self.request.data['cours']))

    @action(detail=True, methods=['post'])
    def soumettre(self, request, pk=None):
        examen = self.get_object()
        if request.user.role != 'ELEVE':
            return Response({"detail": "Non autorisé"}, status=status.HTTP_403_FORBIDDEN)
        serializer = SoumissionExamenSerializer(data=request.data)
        if serializer.is_valid():
            soumission = serializer.save(eleve=request.user, examen=examen)
            enseignant = examen.cours.enseignant
            if enseignant.fcm_token:
                message = messaging.Message(
                    notification=messaging.Notification(
                        title="Nouvelle soumission",
                        body=f"{request.user.username} a soumis l'examen {examen.titre}."
                    ),
                    token=enseignant.fcm_token,
                )
                messaging.send(message)
            # Auto-correction pour QCM
            if examen.type_examen == 'QCM':
                score = 0
                for q in examen.questions.all():
                    if request.data['reponses'].get(str(q.id)) == q.reponses['correct']:
                        score += 1
                soumission.note = (score / examen.questions.count()) * 100
                soumission.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'], url_path='soumissions')
    def get_soumissions(self, request):
        if request.user.role != 'ENSEIGNANT':
            return Response({"detail": "Non autorisé"}, status=status.HTTP_403_FORBIDDEN)
        soumissions = SoumissionExamen.objects.filter(examen__cours__enseignant=request.user)
        serializer = SoumissionExamenSerializer(soumissions, many=True)
        return Response(serializer.data)

class QuestionQCMViewSet(viewsets.ModelViewSet):
    queryset = QuestionQCM.objects.all()
    serializer_class = QuestionQCMSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(examen=Examen.objects.get(id=self.request.data['examen']))

class SoumissionExamenViewSet(viewsets.ModelViewSet):
    queryset = SoumissionExamen.objects.all()
    serializer_class = SoumissionExamenSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if self.request.user.role == 'ELEVE':
            return SoumissionExamen.objects.filter(eleve=self.request.user)
        elif self.request.user.role == 'ENSEIGNANT':
            return SoumissionExamen.objects.filter(examen__cours__enseignant=self.request.user)
        return SoumissionExamen.objects.all()

class BadgeViewSet(viewsets.ModelViewSet):
    queryset = Badge.objects.all()
    serializer_class = BadgeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_permissions(self):
        if self.request.method in ['POST', 'PUT', 'DELETE']:
            return [permissions.IsAdminUser()]
        return [permissions.IsAuthenticated()]

class AttributionBadgeViewSet(viewsets.ModelViewSet):
    queryset = AttributionBadge.objects.all()
    serializer_class = AttributionBadgeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=User.objects.get(id=self.request.data['user']))

class PaiementViewSet(viewsets.ModelViewSet):
    queryset = Paiement.objects.all()
    serializer_class = PaiementSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['post'])
    def ligdicash(self, request):
        # Simulation LigdiCash
        data = request.data
        paiement = Paiement.objects.create(
            user=request.user,
            montant=data['montant'],
            transaction_id=f"txn_{request.user.id}_{int(data['montant'])}"
        )
        paiement.statut = 'SUCCESS'
        paiement.save()
        request.user.is_active = True
        request.user.save()
        return Response({"message": "Paiement réussi", "transaction_id": paiement.transaction_id}, status=status.HTTP_200_OK)

class MessageViewSet(viewsets.ModelViewSet):
    queryset = Message.objects.all()
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(expediteur=self.request.user)

    def get_queryset(self):
        return Message.objects.filter(models.Q(expediteur=self.request.user) | models.Q(destinataire=self.request.user))