from django.db import models
# Create your models here.

class Categoria(models.Model):
    id = models.AutoField(primary_key=True)
    nombre = models.CharField(max_length=50, unique=True)
    class Meta:
        db_table = 'categoria'  #  Este es el nombre real de tu tabla en la base de datos
        managed = False       #  Esto evita que Django intente crear/modificar la tabla
