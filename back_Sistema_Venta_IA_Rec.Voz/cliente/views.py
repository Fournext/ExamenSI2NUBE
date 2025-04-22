from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Cliente
from .serializers import ClienteSerializer
from django.db import connection 
# Create your views here.


@api_view(['POST'])
def registrar_Cliente(request):
    nombre_completo = request.data.get('nombre_completo')
    direccion = request.data.get('direccion')
    telefono = request.data.get('telefono')
    estado = request.data.get('estado')
    username = request.data.get('username')

    if Cliente.objects.filter(nombre_completo=nombre_completo).exists():
            return Response({'error': 'El Cliente ya existe'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "CALL registrar_cliente(%s, %s, %s, %s, %s)", 
                [nombre_completo, direccion, telefono, estado, username]
            )
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return Response({'mensaje': 'Cliente agregado con éxito'}, status=status.HTTP_200_OK)



@api_view(['GET'])
def obtener_clientes(request):
    clientes = Cliente.objects.all()
    serializer = ClienteSerializer(clientes, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['GET'])
def obtener_cliente_nombre(request, nombre):
    try:
        cliente = Cliente.objects.get(nombre_completo=nombre)
        serializer = ClienteSerializer(cliente)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Cliente.DoesNotExist:
        return Response({'error': 'Cliente no encontrado'}, status=status.HTTP_404_NOT_FOUND)
    
@api_view(['POST'])
def actualizar_cliente(request):
    nombre_completo = request.data.get('nombre_completo')
    direccion = request.data.get('direccion')
    telefono = request.data.get('telefono')
    estado = request.data.get('estado')
    id_usuario = request.data.get('id_usuario')
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "CALL actualizar_cliente(%s, %s, %s, %s, %s)", 
                [nombre_completo, direccion, telefono, estado, id_usuario]
            )
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return Response({'mensaje': 'Cliente actualizado con éxito'}, status=status.HTTP_200_OK)

@api_view(['POST'])
def eliminar_cliente(request):
    id_usuario = request.data.get('id_usuario')
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "CALL eliminar_cliente_usuario(%s)", 
                [id_usuario]
            )
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return Response({'mensaje': 'Cliente y Usuario Eliminado con éxito'}, status=status.HTTP_200_OK)


@api_view(['GET'])
def obtener_cliente_por_usuario(request, id_usuario):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM get_cliente_usuario(%s)", [id_usuario])
            row = cursor.fetchone()

            if row is None:
                return Response({'error': 'Cliente no encontrado para este usuario'}, status=status.HTTP_404_NOT_FOUND)

            # Desempaquetar los campos según el orden de la función
            cliente_data = {
                'id_cliente': row[0],
                'nombre_completo': row[1],
                'direccion': row[2],
                'telefono': row[3],
                'estado': row[4],
            }

            return Response(cliente_data, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

@api_view(['POST'])
def insertar_o_actualizar_carrito(request):
    try:
        # Obtener los datos del request
        id_cliente = request.data.get('id_cliente')
        total = request.data.get('total')
        fecha = request.data.get('fecha')
        estado = request.data.get('estado')  


        # Ejecutar la función de PostgreSQL
        with connection.cursor() as cursor:
            cursor.execute("SELECT insertar_o_actualizar_carrito(%s, %s, %s, %s)", [
                id_cliente,
                total,
                fecha,
                estado
            ])
            carrito_id = cursor.fetchone()[0]

        return Response({'id_carrito': carrito_id}, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
def insertar_actualizar_detalle_carrito(request):
    try:
        # Obtener datos del request
        id_carrito = request.data.get('id_carrito')
        id_producto = request.data.get('id_producto')
        cantidad = request.data.get('cantidad')
        precio_unitario = request.data.get('precio_unitario')
        subtotal = request.data.get('subtotal')

        # Validación básica
        if not all([id_carrito, id_producto, cantidad, precio_unitario, subtotal]):
            return Response({'error': 'Faltan datos requeridos'}, status=status.HTTP_400_BAD_REQUEST)

        # Ejecutar la función almacenada
        with connection.cursor() as cursor:
            cursor.execute(
                "CALL insertar_actualizar_detalle_carrito(%s, %s, %s, %s, %s)",
                [id_carrito, id_producto, cantidad, precio_unitario, subtotal]
            )

        return Response({'mensaje': 'Detalle actualizado o insertado con éxito'}, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
@api_view(['DELETE'])
def eliminar_detalle_carrito(request, id_detalle):
    try:
        with connection.cursor() as cursor:
            cursor.execute("CALL eliminar_detalle_carrito(%s)", [id_detalle])

        return Response({'mensaje': 'Detalle del carrito eliminado con éxito'}, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    

@api_view(['GET'])
def obtener_carrito_cliente(request, id_cliente):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM obtener_carrito_cliente(%s)", [id_cliente])
            row = cursor.fetchone()

            if row is None:
                return Response({'mensaje': 'El cliente no tiene un carrito activo'}, status=status.HTTP_404_NOT_FOUND)

            carrito = {
                'id_carrito': row[0],
                'total': float(row[1]),
                'fecha': row[2].isoformat(),  # fecha a string ISO
                'estado': row[3]
            }

            return Response(carrito, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
@api_view(['GET'])
def obtener_detalles_carrito(request, id_carrito):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM obtener_detalles_carrito(%s)", [id_carrito])
            columnas = [col[0] for col in cursor.description]
            detalles = [dict(zip(columnas, fila)) for fila in cursor.fetchall()]

            if not detalles:
                return Response({'mensaje': 'El carrito no tiene productos'}, status=status.HTTP_404_NOT_FOUND)

            return Response({'detalles': detalles}, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

@api_view(['POST'])
def crear_factura_desde_carrito(request):
    try:
        id_carrito = request.data.get('id_carrito')
        id_metodo_pago = request.data.get('id_metodo_pago')

        if not id_carrito or not id_metodo_pago:
            return Response({'error': 'Faltan parámetros requeridos (id_carrito, id_metodo_pago)'}, status=status.HTTP_400_BAD_REQUEST)

        with connection.cursor() as cursor:
            cursor.execute("SELECT crear_factura_desde_carrito(%s, %s)", [id_carrito, id_metodo_pago])
            id_factura = cursor.fetchone()[0]

        return Response({'mensaje': 'Factura creada exitosamente', 'id_factura': id_factura}, status=status.HTTP_201_CREATED)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

@api_view(['GET'])
def obtener_facturas(request):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM obtener_facturas();")
            columnas = [col[0] for col in cursor.description]
            resultados = [
                dict(zip(columnas, fila))
                for fila in cursor.fetchall()
            ]
        return Response(resultados, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
@api_view(['GET'])
def obtener_factura(request, id_factura):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM obtener_factura(%s);", [id_factura])
            columnas = [col[0] for col in cursor.description]
            resultado = cursor.fetchone()

            if resultado:
                factura = dict(zip(columnas, resultado))
                return Response(factura, status=status.HTTP_200_OK)
            else:
                return Response({'mensaje': 'Factura no encontrada'}, status=status.HTTP_404_NOT_FOUND)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
def obtener_detalle_factura(request, id_factura):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM obtener_detalle_factura(%s);", [id_factura])
            columnas = [col[0] for col in cursor.description]
            resultados = [
                dict(zip(columnas, fila))
                for fila in cursor.fetchall()
            ]
        return Response(resultados, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

@api_view(['GET'])
def get_clientes_custom(request):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM get_clientes_custom();")
            columnas = [col[0] for col in cursor.description]
            resultados = [
                dict(zip(columnas, fila))
                for fila in cursor.fetchall()
            ]
            return Response(resultados, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

@api_view(['GET'])
def obtener_compras_por_cliente(request, id_cliente):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM obtener_compras_por_cliente(%s);", [id_cliente])
            columnas = [col[0] for col in cursor.description]
            resultados = [
                dict(zip(columnas, fila))
                for fila in cursor.fetchall()
            ]
            return Response(resultados, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)