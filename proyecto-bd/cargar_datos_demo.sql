USE inventario;

INSERT INTO proveedores (razon_social, telefono, email, direccion)
SELECT 'Proveedor Demo Norte', NULL, 'norte@example.test', 'Direccion de ejemplo 1'
WHERE NOT EXISTS (
  SELECT 1
  FROM proveedores
  WHERE razon_social = 'Proveedor Demo Norte'
);

INSERT INTO proveedores (razon_social, telefono, email, direccion)
SELECT 'Proveedor Demo Sur', NULL, 'sur@example.test', 'Direccion de ejemplo 2'
WHERE NOT EXISTS (
  SELECT 1
  FROM proveedores
  WHERE razon_social = 'Proveedor Demo Sur'
);

INSERT INTO productos (proveedor_id, stock, nombre, precio)
SELECT proveedor.id, 25, 'Producto Demo Teclado', 19.90
FROM proveedores AS proveedor
WHERE proveedor.razon_social = 'Proveedor Demo Norte'
  AND NOT EXISTS (
    SELECT 1
    FROM productos
    WHERE nombre = 'Producto Demo Teclado'
  );

INSERT INTO productos (proveedor_id, stock, nombre, precio)
SELECT proveedor.id, 12, 'Producto Demo Mouse', 9.50
FROM proveedores AS proveedor
WHERE proveedor.razon_social = 'Proveedor Demo Norte'
  AND NOT EXISTS (
    SELECT 1
    FROM productos
    WHERE nombre = 'Producto Demo Mouse'
  );

INSERT INTO productos (proveedor_id, stock, nombre, precio)
SELECT proveedor.id, 8, 'Producto Demo Monitor', 149.99
FROM proveedores AS proveedor
WHERE proveedor.razon_social = 'Proveedor Demo Sur'
  AND NOT EXISTS (
    SELECT 1
    FROM productos
    WHERE nombre = 'Producto Demo Monitor'
  );
