from decimal import Decimal

from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from faker import Faker

from catalogo.models import Producto, Proveedor


class Command(BaseCommand):
    help = "Agrega proveedores y productos ficticios a la base de datos."

    def add_arguments(self, parser):
        parser.add_argument(
            "--cantidad",
            "--proveedores",
            dest="proveedores",
            type=int,
            default=5,
            help="Cantidad de proveedores ficticios que se crearán.",
        )
        parser.add_argument("--productos", type=int, default=20)
        parser.add_argument("--seed", type=int)

    @transaction.atomic
    def handle(self, *args, **options):
        cantidad_proveedores = options["proveedores"]
        cantidad_productos = options["productos"]
        if cantidad_proveedores < 0 or cantidad_productos < 0:
            raise CommandError("Las cantidades no pueden ser negativas.")

        fake = Faker("es")
        if options["seed"] is not None:
            fake.seed_instance(options["seed"])

        telefonos_usados = set(
            Proveedor.objects.exclude(telefono__isnull=True)
            .values_list("telefono", flat=True)
        )
        emails_usados = set(
            Proveedor.objects.exclude(email__isnull=True)
            .values_list("email", flat=True)
        )

        proveedores_creados = []
        for _ in range(cantidad_proveedores):
            telefono = self._valor_unico(
                lambda: fake.numerify("##########"), telefonos_usados
            )
            email = self._valor_unico(fake.email, emails_usados)
            proveedor = Proveedor.objects.create(
                razon_social=fake.company()[:100],
                telefono=telefono,
                email=email,
                direccion=fake.address().replace("\n", ", ")[:120],
            )
            proveedores_creados.append(proveedor)

        if cantidad_productos:
            proveedores_disponibles = list(Proveedor.objects.all())
        else:
            proveedores_disponibles = []

        for _ in range(cantidad_productos):
            proveedor = (
                fake.random_element(proveedores_disponibles)
                if proveedores_disponibles
                else None
            )
            Producto.objects.create(
                proveedor=proveedor,
                stock=fake.random_int(min=0, max=500),
                nombre=fake.sentence(nb_words=4).rstrip(".")[:100],
                precio=(
                    Decimal(fake.random_int(min=100, max=100000)) / Decimal(100)
                ),
            )

        self.stdout.write(
            self.style.SUCCESS(
                f"Se agregaron {len(proveedores_creados)} proveedores y "
                f"{cantidad_productos} productos ficticios."
            )
        )

    @staticmethod
    def _valor_unico(generar, valores_usados):
        for _ in range(100):
            valor = generar()
            if valor not in valores_usados:
                valores_usados.add(valor)
                return valor
        raise CommandError("No se pudo generar un teléfono o correo único.")
