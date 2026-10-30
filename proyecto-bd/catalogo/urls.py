from django.urls import path

from . import views

urlpatterns = [
    path("", views.dashboard, name="dashboard"),
    path("proveedores/nuevo/", views.proveedor_create, name="proveedor_create"),
    path(
        "proveedores/<int:pk>/editar/",
        views.proveedor_update,
        name="proveedor_update",
    ),
    path(
        "proveedores/<int:pk>/eliminar/",
        views.proveedor_delete,
        name="proveedor_delete",
    ),
    path("productos/nuevo/", views.producto_create, name="producto_create"),
    path(
        "productos/<int:pk>/editar/",
        views.producto_update,
        name="producto_update",
    ),
    path(
        "productos/<int:pk>/eliminar/",
        views.producto_delete,
        name="producto_delete",
    ),
]
