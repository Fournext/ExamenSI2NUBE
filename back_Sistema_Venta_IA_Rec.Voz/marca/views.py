from django.db import IntegrityError
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Marca
from .serializers import MarcaSerializer

@api_view(['GET'])
def obtener_marcas(request):
    marcas = Marca.objects.all()
    serializer = MarcaSerializer(marcas, many=True)
    return Response(serializer.data)

@api_view(['GET'])
def obtener_marca_id(request, id):
    try:
        marca = Marca.objects.get(id=id)
        serializer = MarcaSerializer(marca)
        return Response(serializer.data)
    except Marca.DoesNotExist:
        return Response({'error': 'Marca no encontrada'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
def insertar_marca(request):
    serializer = MarcaSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response({'mensaje': 'Marca insertada con éxito'}, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def eliminar_marca(request, id):
    try:
        marca = Marca.objects.get(pk=id)
        marca.delete()
        return Response({'message': 'Marca eliminada con éxito'}, status=status.HTTP_200_OK)
    except Marca.DoesNotExist:
        return Response({'message': 'Marca no encontrada'}, status=status.HTTP_404_NOT_FOUND)
    except IntegrityError:
        return Response({'message': 'No se puede eliminar esta marca porque está siendo usada por productos.'}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])  
def actualizar_marca(request, id):
    try:
        marca = Marca.objects.get(id=id)
    except Marca.DoesNotExist:
        return Response({'error': 'Marca no encontrada'}, status=status.HTTP_404_NOT_FOUND)

    serializer = MarcaSerializer(marca, data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response({'mensaje': 'Marca actualizada con éxito'}, status=status.HTTP_200_OK)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
