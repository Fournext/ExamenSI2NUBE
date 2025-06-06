from django.urls import path
from .views import login,register,agregar_permiso,actualizar_password,obtener_usuario_por_id,obtener_username_por_email,obtener_permisos_usuario,obtener_permisos_usuario_ventana,obtener_tipo_usuario,editar_empleado_usuario,insertar_actualizar_imagen_usuario,obtener_url_usuario

urlpatterns = [
    path('login', login, name='login'),
    path('register', register, name='register'),
    path('permisos', agregar_permiso),
    path('getpermisosUser/<str:username>', obtener_permisos_usuario),
    path('getpermisosUser_Ventana/<str:username>/<str:ventana>', obtener_permisos_usuario_ventana),
    path('newPassword/<str:username>', actualizar_password),
    path('getUser/<int:id_usuario>', obtener_usuario_por_id),
    path('username_email/<str:email>', obtener_username_por_email),
    path('tipo_usuario/<str:username>', obtener_tipo_usuario),

    path('actualizarEmpleadoUsuario', editar_empleado_usuario),

    path('insertarURL', insertar_actualizar_imagen_usuario),
    path('getURL/<int:id_usuario>', obtener_url_usuario),


]