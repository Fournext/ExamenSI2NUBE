from django.db import models
from django.utils import timezone
from datetime import timedelta

class CodigoVerificacion(models.Model):
    codigo = models.CharField(max_length=5, unique=True, primary_key=True)
    expiracion = models.DateTimeField()
    usado = models.BooleanField(default=False)
    
    def es_valido(self):
        # Asegurarse de que 'expiracion' sea un datetime aware
        if self.expiracion.tzinfo is None:
            self.expiracion = timezone.make_aware(self.expiracion, timezone.get_current_timezone())

        # Comparar fechas ahora que ambos son aware
        return not self.usado and self.expiracion > timezone.now()


    def usar_codigo(self):
        """Marca el código como usado."""
        self.usado = True
        self.save()

    def __str__(self):
        return self.codigo
    
    class Meta:
            db_table = 'codigoverificacion'  
            managed = False     