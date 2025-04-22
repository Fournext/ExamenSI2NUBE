from django.urls import path
from .views import registrar_Cliente,obtener_clientes,obtener_cliente_nombre,actualizar_cliente,eliminar_cliente,obtener_cliente_por_usuario,insertar_o_actualizar_carrito, insertar_actualizar_detalle_carrito,eliminar_detalle_carrito,obtener_carrito_cliente,obtener_detalles_carrito,crear_factura_desde_carrito,obtener_facturas,obtener_detalle_factura,obtener_factura,get_clientes_custom,obtener_compras_por_cliente

urlpatterns = [
    path('registrar', registrar_Cliente),
    path('getclientes', obtener_clientes),
    path('getcliente/<str:nombre>', obtener_cliente_nombre),
    path('actualizar', actualizar_cliente),
    path('eliminar', eliminar_cliente),

    path('getcliente_Usuario/<int:id_usuario>', obtener_cliente_por_usuario),
    path('guardarCarrito', insertar_o_actualizar_carrito),
    path('guardarDetalleCarrito', insertar_actualizar_detalle_carrito),
    path('eliminarDetalleCarrito/<int:id_detalle>', eliminar_detalle_carrito),

    path('getCarritoCliente/<int:id_cliente>', obtener_carrito_cliente),
    path('getDetalleCarritoCliente/<int:id_carrito>', obtener_detalles_carrito),

    path('facturaCarrito', crear_factura_desde_carrito),

    path('getFacturas', obtener_facturas),
    path('getFactura/<int:id_factura>', obtener_factura),
    path('getDetalleFactura/<int:id_factura>', obtener_detalle_factura),

    path('getclientesCustom', get_clientes_custom),
    path('getVentaCliente/<int:id_cliente>', obtener_compras_por_cliente),


]