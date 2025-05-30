from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.db import connection 
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import linear_kernel
import pandas as pd
import nltk
nltk.download('stopwords')
from nltk.corpus import stopwords
# Create your views here.


@api_view(['POST'])
def insertar_producto(request):
    descripcion = request.data.get('descripcion')
    categoria = request.data.get('categoria')
    marca = request.data.get('marca')
    estado = request.data.get('estado')
    precio = request.data.get('precio')
    costo = request.data.get('costo')

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "CALL insertar_producto(%s, %s, %s, %s, %s, %s)", 
                [descripcion, categoria, marca, estado, precio, costo]
            )
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return Response({'mensaje': 'Producto insertado con éxito'}, status=status.HTTP_200_OK)
    

@api_view(['POST'])
def actualizar_producto(request, id_producto):
    descripcion = request.data.get('descripcion')
    categoria = request.data.get('categoria')
    marca = request.data.get('marca')
    estado = request.data.get('estado')
    precio = request.data.get('precio')
    costo = request.data.get('costo')
    print(request.data)
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "CALL actualizar_producto(%s, %s, %s, %s, %s, %s, %s)", 
                [id_producto, descripcion, categoria, marca, estado,precio,costo]
            )
    except Exception as e:
        print(e)
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return Response({'mensaje': 'Producto actualizado con éxito'}, status=status.HTTP_200_OK)


@api_view(['GET'])
def get_productos(request):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM get_productos_todo()")
            columns = [col[0] for col in cursor.description]
            productos = [dict(zip(columns, row)) for row in cursor.fetchall()]
        return Response(productos, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

@api_view(['GET'])
def get_producto(request, id_producto):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM get_producto_todo(%s)", [id_producto])
            columns = [col[0] for col in cursor.description]
            producto = dict(zip(columns, cursor.fetchone()))
        
        if producto:
            return Response(producto, status=status.HTTP_200_OK)
        else:
            return Response({'error': 'Producto no encontrado'}, status=status.HTTP_404_NOT_FOUND)
    
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

@api_view(['GET'])
def get_productosFIltro(request):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM get_productos_activos()")
            columns = [col[0] for col in cursor.description]
            productos = [dict(zip(columns, row)) for row in cursor.fetchall()]
        return Response(productos, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

@api_view(['GET'])
def get_productoFiltro(request, id_producto):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM get_producto_activo(%s)", [id_producto])
            columns = [col[0] for col in cursor.description]
            producto = dict(zip(columns, cursor.fetchone()))
        
        if producto:
            return Response(producto, status=status.HTTP_200_OK)
        else:
            return Response({'error': 'Producto no encontrado'}, status=status.HTTP_404_NOT_FOUND)
    
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

@api_view(['POST'])
def eliminar_producto(request,id_producto):
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "CALL eliminar_producto(%s)", 
                [id_producto]
            )
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return Response({'mensaje': 'Producto Eliminado con éxito'}, status=status.HTTP_200_OK)


@api_view(['POST'])
def insertar_actualizar_imagen(request):
    try:
        id_producto = request.data.get('id_producto')
        url = request.data.get('url')

        # Validar que los datos no sean nulos
        if not id_producto or not url:
            return Response({'error': 'Faltan datos requeridos (id_producto o url).'}, status=status.HTTP_400_BAD_REQUEST)

        # Ejecutar el procedimiento
        with connection.cursor() as cursor:
            cursor.execute("CALL insertar_actualizar_imagen_producto(%s, %s)", [id_producto, url])

        return Response({'mensaje': 'Procedimiento ejecutado correctamente.'}, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

@api_view(['GET'])
def obtener_url_producto(request, id_producto):
    try:
        # Ejecutar la función en la base de datos
        with connection.cursor() as cursor:
            cursor.execute("SELECT obtener_url_producto(%s);", [id_producto])
            resultado = cursor.fetchone()  # Obtener el resultado de la función

        # Verificar si se obtuvo algún resultado
        if resultado and resultado[0]:
            return Response({'url': resultado[0]}, status=status.HTTP_200_OK)
        else:
            return Response({'error': 'No se encontró la URL para el producto.'}, status=status.HTTP_404_NOT_FOUND)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

#-----------------------------------------------------------------------------------------------------------------#

def obtener_detalles_factura_df():
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM obtener_todos_detalles_factura()")
        columns = [col[0] for col in cursor.description]
        rows = cursor.fetchall()
    return pd.DataFrame(rows, columns=columns)


def combinar_features(row):
    return f"{row['descripcion_producto']} {row['marca']} {row['descripcion_marca']} {row['categoria']}"


@api_view(['POST'])
def recomendar_productos_por_lista(request):
    try:
        ids_producto = request.data.get('productos', [])
        if not ids_producto:
            return Response({"error": "No se enviaron productos"}, status=400)

        # 1. Obtener datos completos desde la función SQL
        df_completo = obtener_detalles_factura_df()

        # 2. Crear versión reducida para vectorizar sin duplicados y resetear índice
        df_vector = df_completo.drop_duplicates(subset="id_producto").copy().reset_index(drop=True)
        df_vector['caracteristicas'] = df_vector.apply(combinar_features, axis=1)

        # 3. Preparar stopwords y vectorizar
        stopwords_es = stopwords.words('spanish')
        vectorizer = TfidfVectorizer(stop_words=stopwords_es)
        tfidf_matrix = vectorizer.fit_transform(df_vector['caracteristicas'])
        similitudes = linear_kernel(tfidf_matrix, tfidf_matrix)

        # 4. Agrupar cantidades históricas por producto
        cantidades_totales = df_completo.groupby("id_producto")["cantidad"].sum().to_dict()

        # 5. Verificar existencia de productos enviados
        productos_validos = df_vector[df_vector['id_producto'].isin(ids_producto)]
        if productos_validos.empty:
            return Response({
                "error": "Ninguno de los productos enviados fue encontrado en el historial"
            }, status=404)

        # 6. Calcular puntuación ponderada por cantidad
        scores_totales = {}
        for idx, row in df_vector.iterrows():
            if row['id_producto'] in ids_producto:
                peso = cantidades_totales.get(row['id_producto'], 1)
                simil_scores = list(enumerate(similitudes[idx]))
                for i, score in simil_scores:
                    id_simil = df_vector.iloc[i]['id_producto']
                    if id_simil not in ids_producto:
                        scores_totales[i] = scores_totales.get(i, 0) + score * peso

        if not scores_totales:
            return Response({
                "error": "No se encontraron productos similares para recomendar"
            }, status=404)

        # 7. Filtrar índices válidos (evitar index errors)
        top_indices = sorted(scores_totales.items(), key=lambda x: x[1], reverse=True)[:5]
        valid_indices = [i[0] for i in top_indices if i[0] < len(df_vector)]

        if not valid_indices:
            return Response({"error": "No se encontraron productos válidos para recomendar"}, status=404)

        resultado = df_vector.iloc[valid_indices][[
            'id_producto', 'descripcion_producto', 'marca', 'categoria'
        ]]

        return Response(resultado.to_dict(orient='records'))

    except Exception as e:
        print("ERROR:", e)
        return Response({"error": str(e)}, status=500)