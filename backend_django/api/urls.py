from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (UserViewSet, MatiereViewSet, CoursViewSet, ExamenViewSet, QuestionQCMViewSet,
                   SoumissionExamenViewSet, BadgeViewSet, AttributionBadgeViewSet, PaiementViewSet, MessageViewSet)

router = DefaultRouter()
router.register(r'users', UserViewSet)
router.register(r'matieres', MatiereViewSet)
router.register(r'cours', CoursViewSet)
router.register(r'examens', ExamenViewSet)
router.register(r'questions-qcm', QuestionQCMViewSet)
router.register(r'soumissions', SoumissionExamenViewSet)
router.register(r'badges', BadgeViewSet)
router.register(r'attributions-badges', AttributionBadgeViewSet)
router.register(r'paiements', PaiementViewSet)
router.register(r'messages', MessageViewSet)

urlpatterns = [
    path('', include(router.urls)),
]