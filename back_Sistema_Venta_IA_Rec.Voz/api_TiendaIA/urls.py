"""
URL configuration for api_TiendaIA project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path,include


urlpatterns = [
    #path('admin/', admin.site.urls),
    path('api/usuario/', include('usuarios.urls')),
    path('api/cliente/', include('cliente.urls')),
    path('api/empleado/', include('empleado.urls')),
    path('api/recuperar_password/', include('recuperar_password.urls')),
    path('api/categoria/', include('categoria.urls')),
    path('api/marca/', include('marca.urls')),
    path('api/producto/', include('producto.urls')),
    path('api/inventario/', include('inventario.urls')),
]
