from django.urls import path
from .views import insertar_categoria, eliminar_categoria, obtener_categorias, obtener_categoria_id,actualizar_categoria

urlpatterns = [
    path('insertar', insertar_categoria),
    path('eliminar/<int:id>', eliminar_categoria),
    path('getCategorias', obtener_categorias),
    path('getCategoria/<int:id>', obtener_categoria_id),
    path('actualizar/<int:id>', actualizar_categoria),
]
