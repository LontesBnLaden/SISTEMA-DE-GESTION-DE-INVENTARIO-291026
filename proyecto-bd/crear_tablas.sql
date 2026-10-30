CREATE DATABASE IF NOT EXISTS inventario
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE inventario;

CREATE TABLE IF NOT EXISTS proveedores (
  id INT PRIMARY KEY AUTO_INCREMENT,
  razon_social VARCHAR(100) NOT NULL,
  telefono VARCHAR(20) NULL UNIQUE,
  email VARCHAR(100) NULL UNIQUE,
  direccion VARCHAR(120) NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS productos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  proveedor_id INT NULL,
  stock INT NULL DEFAULT 0,
  nombre VARCHAR(100) NOT NULL,
  precio DECIMAL(10, 2) NULL,
  CONSTRAINT fk_productos_proveedores
    FOREIGN KEY (proveedor_id)
    REFERENCES proveedores(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB;
