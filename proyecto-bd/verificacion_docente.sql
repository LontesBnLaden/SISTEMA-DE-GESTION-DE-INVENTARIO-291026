USE inventario;

SELECT DATABASE() AS base_actual, CURRENT_USER() AS usuario_conectado;

SHOW TABLES;

DESCRIBE proveedores;

DESCRIBE productos;

SHOW CREATE TABLE productos;

SELECT
  producto.id,
  producto.nombre,
  producto.stock,
  producto.precio,
  proveedor.razon_social AS proveedor
FROM productos AS producto
LEFT JOIN proveedores AS proveedor
  ON proveedor.id = producto.proveedor_id
ORDER BY producto.id;
