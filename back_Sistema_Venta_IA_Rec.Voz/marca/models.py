from django.db import models
# Create your models here.

class Marca(models.Model):
    id = models.AutoField(primary_key=True)
    nombre = models.CharField(max_length=100, unique=True)
    descripcion_marca = models.CharField(max_length=100)
    class Meta:
        db_table = 'marca'  #  Este es el nombre real de tu tabla en la base de datos
        managed = False       #  Esto evita que Django intente crear/modificar la tabla
