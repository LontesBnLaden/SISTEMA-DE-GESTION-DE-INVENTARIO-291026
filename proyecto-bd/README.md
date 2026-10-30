# Base de datos de inventario

## Avance actual de la clase

El avance actual crea `proveedores` y agrega `productos` relacionado con `proveedores` en la base `inventario`. Esta entrega no vuelve a crear `categorias`.

## Archivos de entrega

- `modelo_logico.puml`: entidades lógicas `Proveedor` y `Producto` y su relación.
- `diagrama.puml`: tablas relacionales `proveedores` y `productos`, con tipos MySQL, claves y restricciones.
- `diagrama.svg`: vista gráfica lista para abrir o imprimir.
- `crear_tablas.sql`: DDL ejecutable en MySQL para crear el esquema `inventario`.
- `inventario.sql`: exportación del esquema conectado, sin datos ni instrucciones `DROP`.
- `cargar_datos_demo.sql`: carga idempotente de proveedores y productos ficticios para una demostración.
- `consultas_presentacion.sql`: consultas para mostrar el JOIN, el conteo por proveedor y las reglas de la FK.
- `verificacion_docente.sql`: muestra la base activa, tablas, estructura y datos relacionados para la exposición.
- `presentar.ps1`: carga los datos de ejemplo y ejecuta las consultas desde PowerShell.
- `conectar_mysql.cmd`: abre MySQL desde CMD con la configuración privada local.
- `configurar_django.ps1` y `iniciar_django.ps1`: crean el entorno virtual, enlazan Django con MySQL e inician la aplicación.
- `catalogo/management/commands/poblar_db.py`: comando Django para agregar proveedores y productos ficticios con Faker.
- `requirements.txt`: dependencias de Django, MySQL y Faker.
- `ESTADO_PROYECTO.md`: resumen de lo realizado, verificaciones y pasos para retomar el trabajo.
- `crear_tablas_oracle.sql`: DDL del mismo modelo en dialecto Oracle.
- `iniciar_mysql.ps1`, `conectar_mysql.ps1` y `detener_mysql.ps1`: scripts para administrar la conexión local.

## Aplicación web Django

La carpeta `inventario_web/` y la aplicación `catalogo/` forman una interfaz CRUD local para productos y proveedores, conectada al mismo esquema MySQL `inventario`. Los modelos Django usan `managed = False`: Django reutiliza las tablas existentes y no las vuelve a crear ni alterar.

Para crear el entorno virtual e instalar Django y el driver MySQL, abre PowerShell en esta carpeta y ejecuta:

```powershell
.\configurar_django.ps1
```

Ese paso lee la conexión privada ya guardada de MySQL y crea `.env` local, excluido del proyecto con `.gitignore`. Después inicia la aplicación en `http://127.0.0.1:8000/`:

```powershell
.\iniciar_django.ps1
```

El lanzador activa el modo de desarrollo para servir los estilos estáticos y el servidor escucha solo en `127.0.0.1`; no comparte la base en la red. `.env` contiene la clave Django y la contraseña de DB codificada para configuración, está excluido por `.gitignore` y no se debe entregar. El script de configuración obtiene la conexión de `%LOCALAPPDATA%\\MySQL\\proyecto_bd\\inventario-client.ini`; nunca pegues credenciales en el código ni en el repositorio. Usa `.venv` para ejecutar Django y el driver `mysqlclient`.

Para agregar datos ficticios desde CMD, ejecuta el comando dentro del proyecto:

```cmd
.venv\Scripts\python.exe manage.py poblar_db --proveedores 5 --productos 20
```

También puedes usar `--cantidad 5` como en el ejemplo de clase; es un alias de `--proveedores`. Los nombres y datos se generan con Faker en español. El comando agrega registros sin borrar ni modificar los existentes. Puedes ajustar las cantidades y usar `--seed 123` para repetir una generación.

## Transformación del modelo lógico a tabla

| Entidad | Columna MySQL | Regla |
|---|---|---|
| Proveedor | `id INT` | PK y autoincremental |
| Proveedor | `razon_social VARCHAR(100)` | Obligatoria |
| Proveedor | `telefono VARCHAR(20)` | Opcional y único |
| Proveedor | `email VARCHAR(100)` | Opcional y único |
| Proveedor | `direccion VARCHAR(120)` | Opcional |
| Producto | `id INT` | PK y autoincremental |
| Producto | `proveedor_id INT` | FK opcional a `proveedores.id` |
| Producto | `stock INT` | Opcional; valor predeterminado `0` |
| Producto | `nombre VARCHAR(100)` | Obligatorio |
| Producto | `precio DECIMAL(10,2)` | Opcional |

En MySQL una columna `UNIQUE` admite varios valores `NULL`, por lo que teléfono y correo pueden omitirse, pero los valores informados no se repiten.

La captura muestra `proveedor_id INT` sin `NOT NULL`, por lo que la columna acepta `NULL`. Esto es compatible con `ON DELETE SET NULL`: al eliminar un proveedor, sus productos se conservan sin proveedor; al actualizar el ID del proveedor, la FK se actualiza en cascada.

## Crear o actualizar el esquema MySQL

MySQL Community Server 8.4 y MySQL Workbench están instalados para el usuario actual. El servidor escucha solo en `127.0.0.1`.

Desde PowerShell, en esta carpeta:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\iniciar_mysql.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\conectar_mysql.ps1
```

Desde CMD, en esta carpeta, abre la consola de MySQL con:

```cmd
conectar_mysql.cmd
```

Para mostrar la estructura como en la clase, ejecuta:

```cmd
conectar_mysql.cmd --table --execute="DESCRIBE productos;"
```

La contraseña se lee del archivo de configuración local; no la escribas en el comando ni la compartas.

En la consola MySQL, ejecutar el DDL:

```sql
SOURCE C:/Users/ESTUDIANTE/Downloads/proyecto-bd/crear_tablas.sql;
```

El script usa `CREATE TABLE IF NOT EXISTS` y no elimina tablas ni registros existentes. Crea `proveedores` antes de `productos` para que la clave foránea pueda referenciarla. Si alguna tabla ya existe con una estructura distinta, revisa su definición antes de volver a ejecutar el DDL; `IF NOT EXISTS` no modifica tablas previas.

`inventario.sql` es una exportación del esquema real de MySQL para guardar o trasladar la estructura. Está pensada para importarse en una base vacía, porque define las tablas sin `IF NOT EXISTS`; para volver a ejecutar de forma segura en esta base utiliza `crear_tablas.sql`.

## Preparar la demostración

Para poblar el esquema local con datos ficticios y mostrar la relación en una sola operación, abre PowerShell en esta carpeta y ejecuta:

```powershell
.\iniciar_mysql.ps1
.\presentar.ps1
```

El script agrega dos proveedores y tres productos con datos inventados; no borra tablas ni registros. Se puede ejecutar varias veces sin duplicar esos registros de ejemplo. Las direcciones de correo usan el dominio reservado `.test`. En MySQL Workbench también puedes ejecutar `cargar_datos_demo.sql` y luego `consultas_presentacion.sql`.

## Mostrar la estructura como en la clase

Para obtener en la terminal la misma descripción que muestra el docente:

```powershell
.\conectar_mysql.ps1 -MySqlArguments @('--table', '--execute=DESCRIBE productos;')
```

También puedes abrir la consola interactiva:

```sql
.\conectar_mysql.ps1
```

En el prompt `mysql>`, ejecuta:

```sql
DESCRIBE productos;
SHOW CREATE TABLE productos;
```

La salida debe mostrar `id` como `PRI` y autoincremental, `proveedor_id` como `MUL` y nullable, `stock` con valor predeterminado `0`, `nombre` obligatorio y `precio` nullable. Usa el usuario local del proyecto, no `root`; `DESCRIBE` funciona igual para verificar la tabla.

Para apagar el servidor:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\detener_mysql.ps1
```

## Conexión con MySQL Workbench

- Connection Method: `Standard (TCP/IP)`
- Hostname: `127.0.0.1`
- Port: `3306`
- Username: `proyecto_user`
- Default Schema: `inventario`
- La contraseña de conexión se guarda localmente en `%LOCALAPPDATA%\MySQL\proyecto_bd\inventario-client.ini`; no se incluye en el proyecto.

## Servidor Ubuntu mostrado en clase

La foto del docente muestra Ubuntu Server y la interfaz `enp0s3` con la dirección IPv4 `192.168.105.121` (máscara `255.255.254.0`). Esto identifica la dirección de red de esa máquina; la foto no confirma que MySQL esté instalado, iniciado o accesible desde otros equipos.

La nueva instrucción de clase indica editar `/etc/mysql/mysql.conf.d/mysqld.cnf` y cambiar `bind-address` de `127.0.0.1` a `0.0.0.0`. Esto hace que MySQL escuche en todas las interfaces de red; por sí solo no configura el firewall, no crea credenciales y no garantiza que el equipo sea alcanzable desde la red del estudiante.

Para realizar ese cambio, solo en un Ubuntu que administres o con autorización del docente:

1. Edita el archivo indicado y guarda el valor mostrado en clase: `bind-address = 0.0.0.0`. Si el ejercicio no requiere escuchar en todas las interfaces, es preferible usar la IP privada de la interfaz del servidor.
2. Antes de reiniciar MySQL, limita el puerto TCP `3306` en el firewall del servidor para permitir únicamente la IP del equipo cliente o la red privada autorizada. No expongas el puerto a Internet ni desactives el firewall. Evita habilitar el firewall remotamente sin conocer las reglas actuales, porque podrías perder acceso al servidor.
3. Reinicia el servicio MySQL (`sudo systemctl restart mysql`) y verifica que esté activo y escuchando (`sudo systemctl status mysql` y `sudo ss -lntp | grep 3306`).
4. Pide al administrador una cuenta dedicada para `inventario`, con acceso desde el host cliente y solo los permisos que el trabajo necesita. No uses `root` ni compartas la contraseña de la conexión local.
5. Si el docente cambia el host, puerto, firewall o permisos, confirma esos datos con él antes de conectarte. La IP `192.168.105.121` de la foto previa puede pertenecer a una red virtual y no ser alcanzable desde tu Windows.

El MySQL configurado en este proyecto es local y se conecta a `127.0.0.1:3306`; el cambio anterior no se ha aplicado a ese servidor. No reemplaces ese host por la IP del aula hasta que el docente confirme que el servicio remoto está disponible y proporcione credenciales para `inventario`. Si autoriza el acceso, crea una conexión nueva en Workbench con:

- Connection Method: `Standard (TCP/IP)`
- Hostname: `192.168.105.121` (confirma que la IP no haya cambiado)
- Port: `3306` (puerto MySQL predeterminado; confirmar con el docente)
- Username y contraseña: los que proporcione el administrador del servidor
- Default Schema: `inventario`

La cuenta local `proyecto_user` y su contraseña guardada localmente no se comparten ni se asume que existan en Ubuntu. Si el docente cambia de red o reinicia su servidor con DHCP, debe confirmar de nuevo la dirección con `ip addr` o `ifconfig`.

## Adaptación del material del docente

El material enlazado incluye instalación/configuración de MySQL en Ubuntu y una guía de conexiones remotas. La sección de acceso remoto usa `bind-address = 0.0.0.0` y ejemplos de cuentas con host comodín y privilegios globales; no apliques esas reglas a este computador para entregar el modelo. Exponen el servicio más allá de `localhost` y conceden más acceso del necesario. Aquí ya está instalado y conectado el MySQL local, escuchando solo en `127.0.0.1:3306`, con el esquema `inventario` y la cuenta limitada del proyecto.

Para comprobar la entrega con una sola ejecución en la consola MySQL local, desde PowerShell ejecuta:

```powershell
.\conectar_mysql.ps1 -MySqlArguments @('--table', '--execute=SOURCE C:/Users/ESTUDIANTE/Downloads/proyecto-bd/verificacion_docente.sql')
```

Este archivo solo ejecuta consultas de lectura: confirma el esquema y el usuario, lista tablas, muestra la descripción de ambas tablas y presenta productos junto al proveedor. No crea usuarios, no cambia contraseñas y no abre conexiones remotas.

## Transformación en Oracle SQL Developer Data Modeler

SQL Developer 26.2, que incluye Data Modeler, está instalado para el usuario actual. PlantUML y los scripts SQL son material de apoyo; el archivo `.dmd` nativo se guarda desde Data Modeler al terminar estos pasos:

1. Abra SQL Developer y seleccione **Tools > Data Modeler > New** para iniciar un diseño.
2. En el modelo lógico, cree las entidades `Proveedor` y `Producto` con los atributos definidos en `modelo_logico.puml`, y relaciónelas con la cardinalidad indicada.
3. Marque `id` como identificador primario en ambas entidades, `telefono`/`email` como únicos y configure la relación para permitir productos sin proveedor.
4. Seleccione **Tools > Data Modeler > Engineer to Relational Model** y revise que se generen `PROVEEDORES` y `PRODUCTOS`, con sus PK, restricciones únicas y FK.
5. Genere el DDL físico para MySQL y compare el resultado con `crear_tablas.sql`. Si el menú no ofrece MySQL como destino, genere Oracle con `crear_tablas_oracle.sql` y use el script MySQL para la base local.
6. Guarde el diseño en esta carpeta con **File > Save**. El `.dmd` y su carpeta de modelos son el entregable nativo que se debe adjuntar.

No importe el DDL para simular el paso lógico → relacional: importar DDL empieza desde un modelo físico existente. El esquema MySQL y el DDL Oracle son alternativas para motores distintos; no se deben ejecutar en el mismo servidor. Oracle no admite `ON UPDATE CASCADE` en una clave foránea, por lo que la variante Oracle conserva `ON DELETE SET NULL` pero no esa acción de actualización. La base local utilizada en esta etapa es MySQL `inventario`.

## Verificación

Conectado como `proyecto_user`, se puede comprobar la tabla y sus restricciones con:

```sql
SHOW CREATE TABLE proveedores;
SHOW INDEX FROM proveedores;
SHOW CREATE TABLE productos;
```

El esquema anterior `proyecto_bd`, creado antes de la actualización de la consigna, se conserva en MySQL y no forma parte de este avance de `inventario`.
