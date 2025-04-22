from django.urls import path
from .views import verificar_codigo,enviar_codigo_correo

urlpatterns = [
    path('enviarEMAIL', enviar_codigo_correo),
    path('verificarCOD', verificar_codigo),

]