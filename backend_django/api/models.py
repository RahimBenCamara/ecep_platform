from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.validators import MinValueValidator

class User(AbstractUser):
    ROLES = (
        ('ELEVE', 'Élève'),
        ('PARENT', 'Parent'),
        ('ENSEIGNANT', 'Enseignant'),
        ('ADMIN', 'Administrateur'),
    )
    role = models.CharField(max_length=10, choices=ROLES, default='ELEVE')
    is_active = models.BooleanField(default=False)
    fcm_token = models.CharField(max_length=255, blank=True, null=True)
    email = models.EmailField(unique=True)
    parent = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, limit_choices_to={'role': 'PARENT'})

class Matiere(models.Model):
    nom = models.CharField(max_length=100)
    description = models.TextField(blank=True)

class Cours(models.Model):
    titre = models.CharField(max_length=255)
    description = models.TextField()
    matiere = models.ForeignKey(Matiere, on_delete=models.CASCADE)
    enseignant = models.ForeignKey(User, on_delete=models.CASCADE, limit_choices_to={'role': 'ENSEIGNANT'})
    fichier = models.FileField(upload_to='cours/', null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

class Ressource(models.Model):
    TYPES = (
        ('VIDEO', 'Vidéo'),
        ('AUDIO', 'Audio'),
        ('PDF', 'PDF'),
        ('IMAGE', 'Image'),
    )
    cours = models.ForeignKey(Cours, on_delete=models.CASCADE, related_name='ressources')
    type_ressource = models.CharField(max_length=10, choices=TYPES)
    fichier = models.FileField(upload_to='ressources/')
    titre = models.CharField(max_length=255)

class Examen(models.Model):
    TYPES = (
        ('QCM', 'QCM'),
        ('REDACTION', 'Rédaction'),
        ('PRATIQUE', 'Pratique'),
    )
    titre = models.CharField(max_length=255)
    type_examen = models.CharField(max_length=10, choices=TYPES)
    cours = models.ForeignKey(Cours, on_delete=models.CASCADE)
    duree = models.IntegerField(validators=[MinValueValidator(1)])
    date_debut = models.DateTimeField()
    date_fin = models.DateTimeField()
    tentatives_max = models.IntegerField(default=1)

class QuestionQCM(models.Model):
    examen = models.ForeignKey(Examen, on_delete=models.CASCADE, limit_choices_to={'type_examen': 'QCM'})
    texte = models.TextField()
    reponses = models.JSONField()  # Ex: {"A": "texte", "B": "texte", "correct": "A"}

class SoumissionExamen(models.Model):
    eleve = models.ForeignKey(User, on_delete=models.CASCADE, limit_choices_to={'role': 'ELEVE'})
    examen = models.ForeignKey(Examen, on_delete=models.CASCADE)
    reponses = models.JSONField(blank=True, null=True)
    fichier = models.FileField(upload_to='soumissions/', null=True, blank=True)
    note = models.FloatField(null=True, blank=True)
    feedback = models.TextField(blank=True)
    submitted_at = models.DateTimeField(auto_now_add=True)

class Badge(models.Model):
    nom = models.CharField(max_length=100)
    description = models.TextField()
    critere = models.CharField(max_length=255)
    image = models.ImageField(upload_to='badges/', null=True)

class AttributionBadge(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    badge = models.ForeignKey(Badge, on_delete=models.CASCADE)
    date_obtention = models.DateTimeField(auto_now_add=True)

class Paiement(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    montant = models.DecimalField(max_digits=10, decimal_places=2)
    date = models.DateTimeField(auto_now_add=True)
    statut = models.CharField(max_length=20, default='PENDING')
    transaction_id = models.CharField(max_length=100, null=True)

class Message(models.Model):
    expediteur = models.ForeignKey(User, on_delete=models.CASCADE, related_name='messages_envoyes')
    destinataire = models.ForeignKey(User, on_delete=models.CASCADE, related_name='messages_recus')
    contenu = models.TextField()
    date_envoi = models.DateTimeField(auto_now_add=True)
    lu = models.BooleanField(default=False)
