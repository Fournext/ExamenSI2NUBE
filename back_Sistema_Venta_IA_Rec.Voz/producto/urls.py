from django.urls import path
from .views import insertar_producto, get_producto, actualizar_producto, get_productos, eliminar_producto, get_productoFiltro,get_productosFIltro,insertar_actualizar_imagen, obtener_url_producto,recomendar_productos_por_lista

urlpatterns = [
    path('insertar', insertar_producto),
    path('actualizar/<int:id_producto>', actualizar_producto),

    path('getProductos', get_productos),
    path('getProducto/<int:id_producto>', get_producto),

    path('getProductosFiltro', get_productosFIltro),
    path('getProductoFiltro/<int:id_producto>', get_productoFiltro),

    path('eliminar/<int:id_producto>', eliminar_producto),

    path('insertarImagen', insertar_actualizar_imagen),
    path('getImagen/<int:id_producto>', obtener_url_producto),

    path('recomendar_productos_por_lista', recomendar_productos_por_lista),



]
