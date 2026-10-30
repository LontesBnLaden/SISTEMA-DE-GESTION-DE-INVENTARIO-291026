# Estado del proyecto

Actualizado: 29 de octubre de 2026

## Objetivo de la entrega

El proyecto documenta las entidades `Proveedor` y `Producto` como tablas MySQL relacionadas y las administra con una aplicación Django conectada a la base de datos local `inventario`. Se decidió usar la base propia de la estudiante; no se configura acceso al servidor del docente.

## Listo y verificado

- Tablas `proveedores` y `productos`, con clave primaria y relación opcional mediante `productos.proveedor_id`.
- La clave foránea usa `ON DELETE SET NULL` y `ON UPDATE CASCADE`.
- Scripts SQL para crear/verificar las tablas, cargar datos ficticios y ejecutar consultas de presentación; diagramas lógico y relacional.
- Aplicación Django con listado/búsqueda y operaciones CRUD para productos y proveedores.
- Los modelos Django usan `managed = False`, por lo que Django no crea ni modifica las tablas existentes.
- Entorno `.venv`, dependencias fijadas en `requirements.txt` y configuración privada `.env`.
- El servidor local usa `127.0.0.1:8000`. Los estilos estáticos responden correctamente.
- Comprobaciones realizadas: `manage.py check --database default` sin errores; panel y formularios respondieron HTTP 200; se probaron altas, cambios y eliminaciones con registros temporales y se comprobó que al eliminar un proveedor los productos se conservan sin proveedor.
- Último recuento leído en MySQL: 3 productos y 3 proveedores. No se incluyen filas de la base local en Git.

## Abrir el proyecto mañana

1. Abrir la carpeta `C:\Users\ESTUDIANTE\Downloads\proyecto-bd` en VS Code.
2. Si MySQL está detenido, abrir PowerShell en esa carpeta y ejecutar:

   ```powershell
   .\iniciar_mysql.ps1
   ```

3. Iniciar la aplicación:

   ```powershell
   .\iniciar_django.ps1
   ```

4. Abrir `http://127.0.0.1:8000/`. Para detener Django, usar `Ctrl+C` en la terminal que ejecutó el script.

Si el entorno virtual o `.env` no existen en esa computadora, ejecutar primero `.\configurar_django.ps1`. Este script usa la configuración privada local de MySQL; no copies contraseñas a los archivos del proyecto.

## Publicación en GitHub: pendiente

- Repositorio público creado: [SISTEMA-DE-GESTION-DE-INVENTARIO-291026](https://github.com/LontesBnLaden/SISTEMA-DE-GESTION-DE-INVENTARIO-291026). GitHub no admite espacios en el nombre.
- La carpeta ya es un repositorio Git local, rama `main`, con el commit inicial `2d82516`. El árbol de trabajo quedó limpio después de ese commit.
- Los intentos de publicación fueron rechazados con HTTP 403 porque Git Credential Manager está autenticado con otra cuenta, sin permiso sobre este repositorio. No se subió ningún archivo; el repositorio remoto sigue sin el proyecto.
- `gh` (GitHub CLI) no está instalado. Para publicar se necesita autenticar Git Credential Manager con la cuenta propietaria `LontesBnLaden`; no compartas contraseñas ni tokens por el chat.
- `.env`, `.venv/`, `__pycache__/`, `*.py[cod]` y `staticfiles/` están excluidos por `.gitignore`. Revisar `git status` antes de cada publicación.
- No guardar ni subir la contraseña de MySQL, la clave de Django, el archivo privado `inventario-client.ini` ni datos personales de la base.

## Siguiente paso

Autenticar Git Credential Manager con `LontesBnLaden` y, desde PowerShell en esta carpeta, ejecutar `git push -u origin main`. Después comprobar que los archivos aparezcan en GitHub y que `.env` y `.venv` no se hayan publicado.
