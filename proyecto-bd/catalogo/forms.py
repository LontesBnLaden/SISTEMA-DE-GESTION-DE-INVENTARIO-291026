from django import forms

from .models import Producto, Proveedor


class ProveedorForm(forms.ModelForm):
    class Meta:
        model = Proveedor
        fields = ["razon_social", "telefono", "email", "direccion"]
        labels = {
            "razon_social": "Razón social",
            "telefono": "Teléfono",
            "email": "Correo electrónico",
            "direccion": "Dirección",
        }
        widgets = {
            "razon_social": forms.TextInput(
                attrs={"placeholder": "Nombre del proveedor"}
            ),
            "telefono": forms.TextInput(attrs={"placeholder": "Opcional"}),
            "email": forms.EmailInput(attrs={"placeholder": "Opcional"}),
            "direccion": forms.TextInput(attrs={"placeholder": "Opcional"}),
        }


class ProductoForm(forms.ModelForm):
    class Meta:
        model = Producto
        fields = ["nombre", "proveedor", "stock", "precio"]
        labels = {
            "nombre": "Nombre del producto",
            "proveedor": "Proveedor",
            "stock": "Unidades en stock",
            "precio": "Precio",
        }
        widgets = {
            "nombre": forms.TextInput(
                attrs={"placeholder": "Ej. Teclado inalámbrico"}
            ),
            "proveedor": forms.Select(attrs={"class": "select-control"}),
            "stock": forms.NumberInput(attrs={"min": 0, "placeholder": "0"}),
            "precio": forms.NumberInput(
                attrs={"min": 0, "step": "0.01", "placeholder": "0.00"}
            ),
        }
