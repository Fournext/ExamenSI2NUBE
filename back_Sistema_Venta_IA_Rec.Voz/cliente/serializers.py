from rest_framework import serializers


class ClienteSerializer(serializers.Serializer):
    nombre_completo = serializers.CharField()
    direccion = serializers.CharField()
    telefono = serializers.CharField()
    estado = serializers.CharField()
    id_usuario = serializers.IntegerField()
