from django.db import models
# Create your models here.

class Cliente(models.Model):
    id = models.AutoField(primary_key=True)
    nombre_completo = models.CharField(max_length=100, unique=True)
    direccion = models.CharField(max_length=255)
    telefono = models.CharField(max_length=15)
    estado = models.CharField(max_length=20)
    id_usuario = models.IntegerField()

    class Meta:
        db_table = 'cliente'  #  Este es el nombre real de tu tabla en la base de datos
        managed = False       #  Esto evita que Django intente crear/modificar la tabla
