from django.db import models
# Create your models here.

class Inventario(models.Model):
    id_inventario = models.AutoField(primary_key=True)
    fecha = models.DateField()
    cantidad = models.IntegerField()
    class Meta:
        db_table = 'inventario'  #  Este es el nombre real de tu tabla en la base de datos
        managed = False       #  Esto evita que Django intente crear/modificar la tabla
