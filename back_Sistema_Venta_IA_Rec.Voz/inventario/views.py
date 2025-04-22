from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.db import connection 
from datetime import datetime
from django.db import IntegrityError
from .models import Inventario
# Create your views here.



@api_view(['POST'])
def insertar_inventario(request):
    print("Request data:", request.data)
    id_producto = request.data.get('id_producto')
    cantidad = request.data.get('cantidad')
    fecha_str = request.data.get('fecha')
    print("Fecha recibida:", fecha_str)  # Debugging line
    fecha = datetime.fromisoformat(fecha_str.replace("Z", "+00:00"))  # Convierte Z a UTC
    print("Fecha convertida:", fecha)  
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "CALL insertar_inventario(%s::INT, %s::INT, %s::TIMESTAMPTZ)", 
                [id_producto, cantidad, fecha]
            )
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    return Response({'mensaje': 'Inventario insertado con éxito'}, status=status.HTTP_200_OK)

@api_view(['GET'])
def get_inventarios(request):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM get_inventarios()")
            columns = [col[0] for col in cursor.description]
            inventarios = [dict(zip(columns, row)) for row in cursor.fetchall()]
        return Response(inventarios, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

@api_view(['POST'])
def actualizar_inventario(request):
    id_inventario = request.data.get('id_inventario')
    cantidad = request.data.get('cantidad')
    fecha_str = request.data.get('fecha')
    fecha = datetime.fromisoformat(fecha_str.replace("Z", "+00:00"))  # Convierte Z a UTC

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "CALL actualizar_inventario(%s::INT, %s::INT, %s::TIMESTAMPTZ)", 
                [id_inventario, cantidad, fecha]
            )
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    return Response({'mensaje': 'Inventario insertado con éxito'}, status=status.HTTP_200_OK)


@api_view(['POST'])
def eliminar_inventario(request, id_inventario):
    try:
        inventario = Inventario.objects.get(pk=id_inventario)
        inventario.delete()
        return Response({'message': 'Inventario eliminado con éxito'}, status=status.HTTP_200_OK)
    except Inventario.DoesNotExist:
        return Response({'message': 'Inventario no encontrado'}, status=status.HTTP_404_NOT_FOUND)
    except IntegrityError:
        return Response({'message': 'No se puede eliminar este inventario porque está siendo usada por productos.'}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
def obtener_ultimo_inventario(request, id_producto):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM obtener_ultimo_inventario(%s)", [id_producto])
            row = cursor.fetchone()

            if row is None:
                return Response({'mensaje': 'No se encontró inventario para este producto'}, status=status.HTTP_404_NOT_FOUND)

            inventario = {
                'id_inventario': row[0],
                'fecha': row[1].isoformat(),
                'cantidad': row[2]
            }

            return Response(inventario, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)