from django.db import models
# Create your models here.

class Producto(models.Model):
    id = models.AutoField(primary_key=True)
    descripcion = models.CharField(max_length=100)
    estado = models.CharField(max_length=20)
    class Meta:
        db_table = 'producto'  #  Este es el nombre real de tu tabla en la base de datos
        managed = False       #  Esto evita que Django intente crear/modificar la tabla
