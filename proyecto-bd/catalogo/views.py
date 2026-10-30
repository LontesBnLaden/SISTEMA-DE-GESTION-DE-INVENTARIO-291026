from django.contrib import messages
from django.db.models import Count, Q
from django.shortcuts import get_object_or_404, redirect, render

from .forms import ProductoForm, ProveedorForm
from .models import Producto, Proveedor


def dashboard(request):
    search = request.GET.get("q", "").strip()
    productos = Producto.objects.select_related("proveedor")
    if search:
        productos = productos.filter(
            Q(nombre__icontains=search)
            | Q(proveedor__razon_social__icontains=search)
        )

    proveedores = Proveedor.objects.annotate(
        total_productos=Count("productos")
    )
    context = {
        "productos": productos,
        "proveedores": proveedores,
        "total_productos": Producto.objects.count(),
        "total_proveedores": Proveedor.objects.count(),
        "search": search,
    }
    return render(request, "catalogo/dashboard.html", context)


def proveedor_create(request):
    form = ProveedorForm(request.POST or None)
    if request.method == "POST" and form.is_valid():
        form.save()
        messages.success(request, "Proveedor guardado correctamente.")
        return redirect("dashboard")
    return render(
        request,
        "catalogo/proveedor_form.html",
        {"form": form, "titulo": "Nuevo proveedor"},
    )


def proveedor_update(request, pk):
    proveedor = get_object_or_404(Proveedor, pk=pk)
    form = ProveedorForm(request.POST or None, instance=proveedor)
    if request.method == "POST" and form.is_valid():
        form.save()
        messages.success(request, "Proveedor actualizado correctamente.")
        return redirect("dashboard")
    return render(
        request,
        "catalogo/proveedor_form.html",
        {"form": form, "titulo": "Editar proveedor"},
    )


def proveedor_delete(request, pk):
    proveedor = get_object_or_404(Proveedor, pk=pk)
    if request.method == "POST":
        proveedor.delete()
        messages.success(
            request,
            "Proveedor eliminado. Sus productos se conservaron sin proveedor.",
        )
        return redirect("dashboard")
    return render(
        request,
        "catalogo/confirm_delete.html",
        {
            "objeto": proveedor,
            "tipo": "proveedor",
            "volver": "dashboard",
        },
    )


def producto_create(request):
    form = ProductoForm(request.POST or None)
    if request.method == "POST" and form.is_valid():
        form.save()
        messages.success(request, "Producto guardado correctamente.")
        return redirect("dashboard")
    return render(
        request,
        "catalogo/producto_form.html",
        {"form": form, "titulo": "Nuevo producto"},
    )


def producto_update(request, pk):
    producto = get_object_or_404(Producto, pk=pk)
    form = ProductoForm(request.POST or None, instance=producto)
    if request.method == "POST" and form.is_valid():
        form.save()
        messages.success(request, "Producto actualizado correctamente.")
        return redirect("dashboard")
    return render(
        request,
        "catalogo/producto_form.html",
        {"form": form, "titulo": "Editar producto"},
    )


def producto_delete(request, pk):
    producto = get_object_or_404(Producto, pk=pk)
    if request.method == "POST":
        producto.delete()
        messages.success(request, "Producto eliminado correctamente.")
        return redirect("dashboard")
    return render(
        request,
        "catalogo/confirm_delete.html",
        {
            "objeto": producto,
            "tipo": "producto",
            "volver": "dashboard",
        },
    )
