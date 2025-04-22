from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import smtplib
from django.shortcuts import render
import random
from datetime import timedelta
from django.utils import timezone
from .models import CodigoVerificacion
from dotenv import load_dotenv
import os
from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import api_view

load_dotenv()

def generar_codigo():
    codigo = str(random.randint(10000, 99999))
    expiracion = timezone.now() + timedelta(minutes=10)  # Fecha de expiración (10 minutos)
    
    nuevo_codigo = CodigoVerificacion(codigo=codigo, expiracion=expiracion)
    nuevo_codigo.save()
    return codigo 

@api_view(['POST'])
def enviar_codigo_correo(request):
    # Obtener el correo electrónico del destinatario desde la solicitud
    destinatario = request.data.get('email')

    if not destinatario:
        return Response({'error': 'El campo "email" es obligatorio.'}, status=status.HTTP_400_BAD_REQUEST)

    codigo = generar_codigo()
    remitente = os.getenv('EMAIL')
    password = os.getenv('EMAIL_PASSWORD') 
    
    # Crear el mensaje de correo
    subject = "Tu código único"
    body = f"Tu código único de 5 dígitos es: {codigo}"
    
    # Enviar el correo
    try:
        with smtplib.SMTP('smtp.gmail.com', 587) as server:
            server.starttls() 
            server.login(remitente, password)

            msg = MIMEMultipart()
            msg['From'] = remitente
            msg['To'] = destinatario
            msg['Subject'] = subject
            msg.attach(MIMEText(body, 'plain'))

            server.sendmail(remitente, destinatario, msg.as_string())
        return Response({'mensaje': 'Correo enviado con éxito'}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({'error': f"Error al enviar el correo: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
def verificar_codigo(request):  # Cambiado para recibir request
    codigo = request.data.get('codigo')  # Obtener código del request
    
    if not codigo:
        return Response({'error': 'El campo "codigo" es obligatorio.',
                         'valido':True}, status=status.HTTP_400_BAD_REQUEST)

    try:
        # Buscar el código en la base de datos
        codigo_obj = CodigoVerificacion.objects.get(codigo=codigo)

        # Verificar si el código es válido (no expiró y no ha sido usado)
        if codigo_obj.es_valido():  # Asegúrate de que este método esté definido en tu modelo
            # Marcar el código como usado
            codigo_obj.usar_codigo()  # Asegúrate de que este método esté definido en tu modelo
            return Response({'mensaje': 'Código verificado con éxito'}, status=status.HTTP_200_OK)
        else:
            return Response({'error': 'El código ha expirado o ya ha sido usado'}, status=status.HTTP_400_BAD_REQUEST)
    except CodigoVerificacion.DoesNotExist:
        return Response({'error': 'Código no válido',
                         'valido':False}, status=status.HTTP_400_BAD_REQUEST)