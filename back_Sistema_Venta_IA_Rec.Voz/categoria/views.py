from django.db import IntegrityError
from .serializers import CategoriaSerializer
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Categoria




@api_view(['POST'])
def insertar_categoria(request):
    serializer = CategoriaSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response({'mensaje': 'Categoría insertada con éxito'}, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
def obtener_categorias(request):
    categorias = Categoria.objects.all()
    serializer = CategoriaSerializer(categorias, many=True)
    return Response(serializer.data)

@api_view(['GET'])
def obtener_categoria_id(request, id):
    try:
        categoria = Categoria.objects.get(id=id)
        serializer = CategoriaSerializer(categoria)
        return Response(serializer.data)
    except Categoria.DoesNotExist:
        return Response({'error': 'Categoría no encontrada'}, status=status.HTTP_404_NOT_FOUND)



@api_view(['POST'])
def eliminar_categoria(request, id):
    try:
        categoria = Categoria.objects.get(id=id)
        categoria.delete()
        return Response({'mensaje': 'Categoría eliminada con éxito'}, status=status.HTTP_200_OK)
    except Categoria.DoesNotExist:
        return Response({'error': 'Categoría no encontrada'}, status=status.HTTP_404_NOT_FOUND)
    except IntegrityError:
        return Response({
            'error': 'No se puede eliminar la categoría porque está siendo utilizada por uno o más productos.'
        }, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])  
def actualizar_categoria(request, id):
    try:
        categoria = Categoria.objects.get(id=id)
    except Categoria.DoesNotExist:
        return Response({'error': 'Categoria no encontrada'}, status=status.HTTP_404_NOT_FOUND)

    serializer = CategoriaSerializer(categoria, data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response({'mensaje': 'Categoria actualizada con éxito'}, status=status.HTTP_200_OK)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)