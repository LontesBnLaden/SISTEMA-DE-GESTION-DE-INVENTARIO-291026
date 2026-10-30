USE inventario;

SELECT
  producto.id AS producto_id,
  producto.nombre AS producto,
  producto.stock,
  producto.precio,
  proveedor.razon_social AS proveedor
FROM productos AS producto
LEFT JOIN proveedores AS proveedor
  ON proveedor.id = producto.proveedor_id
ORDER BY producto.id;

SELECT
  proveedor.razon_social AS proveedor,
  COUNT(producto.id) AS cantidad_productos
FROM proveedores AS proveedor
LEFT JOIN productos AS producto
  ON producto.proveedor_id = proveedor.id
GROUP BY proveedor.id, proveedor.razon_social
ORDER BY proveedor.razon_social;

SELECT
  CONSTRAINT_NAME,
  DELETE_RULE,
  UPDATE_RULE
FROM information_schema.REFERENTIAL_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = DATABASE()
  AND TABLE_NAME = 'productos';
