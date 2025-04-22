from django.urls import path
from .views import obtener_marcas,obtener_marca_id, insertar_marca, eliminar_marca, actualizar_marca

urlpatterns = [
    path('getMarcas', obtener_marcas),
    path('getMarca/<int:id>', obtener_marca_id),
    path('insertar', insertar_marca),
    path('eliminar/<int:id>', eliminar_marca),
    path('actualizar/<int:id>', actualizar_marca),
]
