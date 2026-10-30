from django.db import models


class Proveedor(models.Model):
    id = models.AutoField(primary_key=True)
    razon_social = models.CharField(max_length=100)
    telefono = models.CharField(max_length=20, blank=True, null=True, unique=True)
    email = models.CharField(max_length=100, blank=True, null=True, unique=True)
    direccion = models.CharField(max_length=120, blank=True, null=True)

    class Meta:
        managed = False
        db_table = "proveedores"
        ordering = ["razon_social"]
        verbose_name = "proveedor"
        verbose_name_plural = "proveedores"

    def __str__(self) -> str:
        return self.razon_social


class Producto(models.Model):
    id = models.AutoField(primary_key=True)
    proveedor = models.ForeignKey(
        Proveedor,
        db_column="proveedor_id",
        related_name="productos",
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
    )
    stock = models.IntegerField(default=0, blank=True, null=True)
    nombre = models.CharField(max_length=100)
    precio = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        blank=True,
        null=True,
    )

    class Meta:
        managed = False
        db_table = "productos"
        ordering = ["nombre"]
        verbose_name = "producto"
        verbose_name_plural = "productos"

    def __str__(self) -> str:
        return self.nombre
