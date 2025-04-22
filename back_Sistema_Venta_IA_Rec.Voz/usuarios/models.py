from django.db import models
from django.contrib.auth.hashers import make_password, check_password
# Create your models here.

class Usuario(models.Model):
    id = models.AutoField(primary_key=True)
    username = models.CharField(max_length=50, unique=True)
    password = models.CharField(max_length=255)
    email = models.EmailField(max_length=255)
    tipo_usuario = models.CharField(max_length=20)
    estado = models.CharField(max_length=20)

    def set_password(self, raw_password):
        self.password = make_password(raw_password)

    def check_password(self, raw_password):
        return check_password(raw_password, self.password)

    def __str__(self):
        return self.username
    class Meta:
        db_table = 'usuario'  #  Este es el nombre real de tu tabla en la base de datos
        managed = False       #  Esto evita que Django intente crear/modificar la tabla
