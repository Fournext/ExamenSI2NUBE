PGDMP  +    (                }            DB_PuntoVenta    17.4    17.4 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            �           1262    18599    DB_PuntoVenta    DATABASE     u   CREATE DATABASE "DB_PuntoVenta" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'es-MX';
    DROP DATABASE "DB_PuntoVenta";
                     postgres    false                       1255    19326 g   actualizar_cliente(character varying, character varying, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.actualizar_cliente(IN p_nombre_completo character varying, IN p_direccion character varying, IN p_telefono character varying, IN p_estado character varying, IN p_id_usuario integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verifica si existe un cliente con el id_usuario proporcionado
    IF EXISTS (SELECT 1 FROM cliente WHERE id_usuario = p_id_usuario) THEN
        -- Actualiza los datos del cliente
        UPDATE cliente
        SET nombre_completo = p_nombre_completo,
            direccion = p_direccion,
            telefono = p_telefono,
            estado = p_estado
        WHERE id_usuario = p_id_usuario;

        -- Si el estado del cliente se actualiza, también actualiza el estado del usuario
        IF p_estado IS NOT NULL THEN
            UPDATE usuario
            SET estado = p_estado
            WHERE id = p_id_usuario;
        END IF;
    ELSE
        RAISE EXCEPTION 'No existe un cliente con el id_usuario: %', p_id_usuario;
    END IF;
END;
$$;
 �   DROP PROCEDURE public.actualizar_cliente(IN p_nombre_completo character varying, IN p_direccion character varying, IN p_telefono character varying, IN p_estado character varying, IN p_id_usuario integer);
       public               postgres    false                       1255    19329 �   actualizar_empleado(character varying, character varying, character varying, character varying, date, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.actualizar_empleado(IN p_nombre_completo character varying, IN p_direccion character varying, IN p_telefono character varying, IN p_rol character varying, IN p_fecha_nacimiento date, IN p_estado character varying, IN p_id_usuario integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verificamos si existe un empleado con ese id_usuario
    IF NOT EXISTS (SELECT 1 FROM empleado WHERE id_usuario = p_id_usuario) THEN
        RAISE EXCEPTION 'No se encontró un empleado con id_usuario: %', p_id_usuario;
    END IF;

    -- Realizamos la actualización
    UPDATE empleado
    SET 
        nombre_completo = p_nombre_completo,
        direccion = p_direccion,
        telefono = p_telefono,
        rol = p_rol,
        fecha_nacimiento = p_fecha_nacimiento,
        estado = p_estado
    WHERE id_usuario = p_id_usuario;

	IF p_estado IS NOT NULL THEN
            UPDATE usuario
            SET estado = p_estado
            WHERE id = p_id_usuario;
        END IF;
END;
$$;
   DROP PROCEDURE public.actualizar_empleado(IN p_nombre_completo character varying, IN p_direccion character varying, IN p_telefono character varying, IN p_rol character varying, IN p_fecha_nacimiento date, IN p_estado character varying, IN p_id_usuario integer);
       public               postgres    false            %           1255    19458 A   actualizar_inventario(integer, integer, timestamp with time zone) 	   PROCEDURE     �  CREATE PROCEDURE public.actualizar_inventario(IN p_id_inventario integer, IN p_cantidad integer, IN p_fecha timestamp with time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verificar si existe el inventario
    IF EXISTS (SELECT 1 FROM inventario WHERE id_inventario = p_id_inventario) THEN
        -- Actualizar inventario
        UPDATE inventario
        SET cantidad = p_cantidad,
            fecha = p_fecha
        WHERE id_inventario = p_id_inventario;

        RAISE NOTICE 'Inventario actualizado correctamente. ID: %', p_id_inventario;
    ELSE
        -- Lanzar excepción si no existe
        RAISE EXCEPTION 'Inventario con ID % no encontrado.', p_id_inventario;
    END IF;
END;
$$;
 �   DROP PROCEDURE public.actualizar_inventario(IN p_id_inventario integer, IN p_cantidad integer, IN p_fecha timestamp with time zone);
       public               postgres    false                       1255    19492 "   actualizar_inventario_tras_venta()    FUNCTION     R  CREATE FUNCTION public.actualizar_inventario_tras_venta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Actualizar el inventario del producto: restar cantidad y actualizar fecha
  UPDATE inventario
  SET 
    cantidad = cantidad - NEW.cantidad,
    fecha = NOW()
  WHERE id_producto = NEW.id_producto;

  RETURN NEW;
END;
$$;
 9   DROP FUNCTION public.actualizar_inventario_tras_venta();
       public               postgres    false                       1255    19338 h   actualizar_producto(integer, character varying, character varying, character varying, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.actualizar_producto(IN p_id_producto integer, IN p_descripcion character varying, IN p_categoria character varying, IN p_marca character varying, IN p_estado character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_categoria INT;
    v_id_marca INT;
BEGIN
    -- Buscar ID de categoría por nombre
    SELECT id INTO v_id_categoria FROM categoria WHERE nombre = p_categoria;
    IF v_id_categoria IS NULL THEN
        RAISE EXCEPTION 'No se encontró la categoría: %', p_categoria;
    END IF;

    -- Buscar ID de marca por nombre
    SELECT id INTO v_id_marca FROM marca WHERE nombre = p_marca;
    IF v_id_marca IS NULL THEN
        RAISE EXCEPTION 'No se encontró la marca: %', p_marca;
    END IF;

    -- Actualizar producto
    UPDATE producto
    SET descripcion = p_descripcion,
        id_categoria = v_id_categoria,
        id_marca = v_id_marca,
        estado = p_estado
    WHERE id = p_id_producto;
END;
$$;
 �   DROP PROCEDURE public.actualizar_producto(IN p_id_producto integer, IN p_descripcion character varying, IN p_categoria character varying, IN p_marca character varying, IN p_estado character varying);
       public               postgres    false                       1255    19380 z   actualizar_producto(integer, character varying, character varying, character varying, character varying, numeric, numeric) 	   PROCEDURE     X  CREATE PROCEDURE public.actualizar_producto(IN p_id_producto integer, IN p_descripcion character varying, IN p_categoria character varying, IN p_marca character varying, IN p_estado character varying, IN p_precio numeric, IN p_costo numeric)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_categoria INT;
    v_id_marca INT;
BEGIN
    -- Verificar existencia del producto
    IF NOT EXISTS (SELECT 1 FROM producto WHERE id = p_id_producto) THEN
        RAISE EXCEPTION 'No existe un producto con el ID: %', p_id_producto;
    END IF;

    -- Buscar ID de categoría por nombre
    SELECT id INTO v_id_categoria FROM categoria WHERE nombre = p_categoria;
    IF v_id_categoria IS NULL THEN
        RAISE EXCEPTION 'No se encontró la categoría: %', p_categoria;
    END IF;

    -- Buscar ID de marca por nombre
    SELECT id INTO v_id_marca FROM marca WHERE nombre = p_marca;
    IF v_id_marca IS NULL THEN
        RAISE EXCEPTION 'No se encontró la marca: %', p_marca;
    END IF;

    -- Actualizar producto
    UPDATE producto
    SET descripcion = p_descripcion,
        id_categoria = v_id_categoria,
        id_marca = v_id_marca,
        estado = p_estado
    WHERE id = p_id_producto;

    -- Insertar nuevo historial de costo
    INSERT INTO costo_producto (
        id_producto,
        costo,
        fecha
    ) VALUES (
        p_id_producto,
        p_costo,
        CURRENT_DATE
    );

    -- Insertar nuevo historial de precio
    INSERT INTO precio_producto (
        id_producto,
        precio,
        fecha
    ) VALUES (
        p_id_producto,
        p_precio,
        CURRENT_DATE
    );
END;
$$;
 �   DROP PROCEDURE public.actualizar_producto(IN p_id_producto integer, IN p_descripcion character varying, IN p_categoria character varying, IN p_marca character varying, IN p_estado character varying, IN p_precio numeric, IN p_costo numeric);
       public               postgres    false            /           1255    19488    actualizar_total_carrito()    FUNCTION     �  CREATE FUNCTION public.actualizar_total_carrito() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_id_carrito INT;
  v_total_base DECIMAL := 0;
  v_descuento DECIMAL := 0;
BEGIN
  -- Determinar el carrito afectado
  IF (TG_OP = 'DELETE') THEN
    v_id_carrito := OLD.id_carrito;
  ELSE
    v_id_carrito := NEW.id_carrito;
  END IF;

  -- Calcular el total normal (sin descuentos)
  SELECT COALESCE(SUM(subtotal), 0)
  INTO v_total_base
  FROM detalle_carrito
  WHERE id_carrito = v_id_carrito;

  -- Calcular el descuento: 10% de la suma de subtotales de productos con cantidad > 5
  SELECT COALESCE(SUM(subtotal) * 0.10, 0)
  INTO v_descuento
  FROM detalle_carrito
  WHERE id_carrito = v_id_carrito AND cantidad > 5;

  -- Actualizar el total del carrito aplicando el descuento
  UPDATE carrito
  SET total = v_total_base - v_descuento
  WHERE id = v_id_carrito;

  RETURN NULL;
END;
$$;
 1   DROP FUNCTION public.actualizar_total_carrito();
       public               postgres    false            .           1255    19487 -   crear_factura_desde_carrito(integer, integer)    FUNCTION     i  CREATE FUNCTION public.crear_factura_desde_carrito(p_id_carrito integer, p_id_metodo_pago integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_id_factura INT;
  v_id_cliente INT;
  v_total DECIMAL;
  v_fecha DATE;
BEGIN
  -- Obtener datos del carrito
  SELECT id_cliente, total, fecha
  INTO v_id_cliente, v_total, v_fecha
  FROM carrito
  WHERE id = p_id_carrito;

  -- Insertar la factura
  INSERT INTO factura (
    fecha,
    id_cliente,
    total,
    id_metodo_pago,
    estado
  ) VALUES (
    v_fecha,
    v_id_cliente,
    v_total,
    p_id_metodo_pago,
    'emitida'
  )
  RETURNING id INTO v_id_factura;

  -- Insertar los detalles del carrito como detalles de factura
  INSERT INTO detalle_factura (
    id_factura,
    id_producto,
    cantidad,
    precio_unitario
  )
  SELECT 
    v_id_factura,
    dc.id_producto,
    dc.cantidad,
    dc.precio_unitario
  FROM detalle_carrito dc
  WHERE dc.id_carrito = p_id_carrito;

  -- Marcar el carrito como finalizado
  UPDATE carrito
  SET estado = 'finalizado'
  WHERE id = p_id_carrito;

  -- Retornar el id de la factura
  RETURN v_id_factura;
END;
$$;
 b   DROP FUNCTION public.crear_factura_desde_carrito(p_id_carrito integer, p_id_metodo_pago integer);
       public               postgres    false            
           1255    19490 !   descontar_inventario_tras_venta()    FUNCTION     V  CREATE FUNCTION public.descontar_inventario_tras_venta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Insertar movimiento de salida en el inventario (cantidad negativa)
  INSERT INTO inventario (
    id_producto,
    fecha,
    cantidad
  ) VALUES (
    NEW.id_producto,
    NOW(),
    -NEW.cantidad
  );

  RETURN NEW;
END;
$$;
 8   DROP FUNCTION public.descontar_inventario_tras_venta();
       public               postgres    false            2           1255    19515 r   editar_empleado_usuario(integer, character varying, character varying, character varying, character varying, date) 	   PROCEDURE     �  CREATE PROCEDURE public.editar_empleado_usuario(IN p_id_usuario integer, IN p_nombre_empleado character varying, IN p_email character varying, IN p_telefono character varying, IN p_direccion character varying, IN p_fecha_nacimiento date)
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Actualizar información en la tabla empleado
  UPDATE empleado
  SET 
    nombre_completo = p_nombre_empleado,
    telefono = p_telefono,
    direccion = p_direccion,
    fecha_nacimiento = p_fecha_nacimiento
  WHERE id_usuario = p_id_usuario;

  -- Actualizar email en la tabla usuario
  UPDATE usuario
  SET email = p_email
  WHERE id = p_id_usuario;
END;
$$;
 �   DROP PROCEDURE public.editar_empleado_usuario(IN p_id_usuario integer, IN p_nombre_empleado character varying, IN p_email character varying, IN p_telefono character varying, IN p_direccion character varying, IN p_fecha_nacimiento date);
       public               postgres    false            0           1255    19510     eliminar_carrito_si_finalizado()    FUNCTION     �  CREATE FUNCTION public.eliminar_carrito_si_finalizado() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Si el carrito actualizado tiene estado 'finalizado'
  IF NEW.estado = 'finalizado' THEN
    -- Eliminar detalles asociados
    DELETE FROM detalle_carrito
    WHERE id_carrito = NEW.id;

    -- Eliminar el carrito en sí
    DELETE FROM carrito
    WHERE id = NEW.id;
  END IF;

  RETURN NULL; -- no se necesita continuar con la fila porque fue eliminada
END;
$$;
 7   DROP FUNCTION public.eliminar_carrito_si_finalizado();
       public               postgres    false            �            1255    19327 !   eliminar_cliente_usuario(integer) 	   PROCEDURE     �  CREATE PROCEDURE public.eliminar_cliente_usuario(IN p_id_usuario integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verifica si existe un cliente con ese id_usuario
    IF EXISTS (SELECT 1 FROM cliente WHERE id_usuario = p_id_usuario) THEN
        -- Actualiza el estado del cliente a 'eliminado'
        UPDATE cliente
        SET estado = 'eliminado'
        WHERE id_usuario = p_id_usuario;

        -- También actualiza el estado del usuario a 'eliminado'
        UPDATE usuario
        SET estado = 'eliminado'
        WHERE id = p_id_usuario;
    ELSE
        RAISE EXCEPTION 'No existe un cliente asociado al id_usuario: %', p_id_usuario;
    END IF;
END;
$$;
 I   DROP PROCEDURE public.eliminar_cliente_usuario(IN p_id_usuario integer);
       public               postgres    false            +           1255    19484 !   eliminar_detalle_carrito(integer) 	   PROCEDURE     �   CREATE PROCEDURE public.eliminar_detalle_carrito(IN p_id_detalle integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM detalle_carrito
  WHERE id = p_id_detalle;
END;
$$;
 I   DROP PROCEDURE public.eliminar_detalle_carrito(IN p_id_detalle integer);
       public               postgres    false                       1255    19330 "   eliminar_empleado_usuario(integer) 	   PROCEDURE     �  CREATE PROCEDURE public.eliminar_empleado_usuario(IN p_id_usuario integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verifica si existe un empleado con ese id_usuario
    IF EXISTS (SELECT 1 FROM empleado WHERE id_usuario = p_id_usuario) THEN
        -- Actualiza el estado del empleado a 'eliminado'
        UPDATE empleado
        SET estado = 'eliminado'
        WHERE id_usuario = p_id_usuario;

        -- También actualiza el estado del usuario a 'eliminado'
        UPDATE usuario
        SET estado = 'eliminado'
        WHERE id = p_id_usuario;
    ELSE
        RAISE EXCEPTION 'No existe un empleado asociado al id_usuario: %', p_id_usuario;
    END IF;
END;
$$;
 J   DROP PROCEDURE public.eliminar_empleado_usuario(IN p_id_usuario integer);
       public               postgres    false                       1255    19340    eliminar_producto(integer) 	   PROCEDURE     �  CREATE PROCEDURE public.eliminar_producto(IN p_id_producto integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verificar existencia
    IF NOT EXISTS (SELECT 1 FROM producto WHERE id = p_id_producto) THEN
        RAISE EXCEPTION 'No se encontró el producto con ID: %', p_id_producto;
    END IF;

    -- Eliminación lógica
    UPDATE producto
    SET estado = 'eliminado'
    WHERE id = p_id_producto;
END;
$$;
 C   DROP PROCEDURE public.eliminar_producto(IN p_id_producto integer);
       public               postgres    false                        1255    19476    get_cliente_usuario(integer)    FUNCTION     �  CREATE FUNCTION public.get_cliente_usuario(p_id_usuario integer) RETURNS TABLE(id_cliente integer, nombre_completo character varying, direccion character varying, telefono character varying, estado character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.nombre_completo,
    c.direccion,
    c.telefono,
    c.estado
  FROM cliente c
  WHERE c.id_usuario = p_id_usuario;
END;
$$;
 @   DROP FUNCTION public.get_cliente_usuario(p_id_usuario integer);
       public               postgres    false                       1255    19498    get_clientes_custom()    FUNCTION     ;  CREATE FUNCTION public.get_clientes_custom() RETURNS TABLE(id integer, nombre character varying, email character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.nombre_completo,
        u.email
    FROM cliente c
    JOIN usuario u ON c.id_usuario = u.id;
END;
$$;
 ,   DROP FUNCTION public.get_clientes_custom();
       public               postgres    false            $           1255    19444    get_inventarios()    FUNCTION     �  CREATE FUNCTION public.get_inventarios() RETURNS TABLE(id_inventario integer, producto character varying, cantidad integer, fecha timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        i.id_inventario,
        p.descripcion,
        i.cantidad,
        i.fecha
    FROM inventario i
    JOIN producto p ON i.id_producto = p.id
    ORDER BY i.fecha DESC;
END;
$$;
 (   DROP FUNCTION public.get_inventarios();
       public               postgres    false            #           1255    19435 '   get_permisos_usuario(character varying)    FUNCTION     �  CREATE FUNCTION public.get_permisos_usuario(p_username character varying) RETURNS TABLE(ventana character varying, insertar boolean, editar boolean, eliminar boolean, ver boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pe.ventana,
        pe.insertar,
        pe.editar,
        pe.eliminar,
        pe.ver
    FROM permisos pe
    JOIN usuario u ON pe.id_usuario = u.id
    WHERE u.username = p_username;
END;
$$;
 I   DROP FUNCTION public.get_permisos_usuario(p_username character varying);
       public               postgres    false            �            1255    19460 B   get_permisos_usuario_ventana(character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.get_permisos_usuario_ventana(p_username character varying, p_ventana character varying) RETURNS TABLE(insertar boolean, editar boolean, eliminar boolean, ver boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        per.insertar,
        per.editar,
        per.eliminar,
        per.ver
    FROM usuario u
    JOIN permisos per ON per.id_usuario = u.id
    WHERE u.username = p_username AND per.ventana = p_ventana;
END;
$$;
 n   DROP FUNCTION public.get_permisos_usuario_ventana(p_username character varying, p_ventana character varying);
       public               postgres    false            !           1255    19408    get_producto_activo(integer)    FUNCTION     �  CREATE FUNCTION public.get_producto_activo(p_id_producto integer) RETURNS TABLE(id integer, descripcion character varying, categoria character varying, marca character varying, descripcion_marca character varying, costo numeric, precio numeric, estado character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH ultimo_costo AS (
        SELECT 
            cp.id_producto AS uc_id_producto,
            cp.costo AS uc_costo,
            ROW_NUMBER() OVER (PARTITION BY cp.id_producto ORDER BY cp.fecha DESC) AS uc_rn
        FROM costo_producto cp
    ),
    ultimo_precio AS (
        SELECT 
            pp.id_producto AS up_id_producto,
            pp.precio AS up_precio,
            ROW_NUMBER() OVER (PARTITION BY pp.id_producto ORDER BY pp.fecha DESC) AS up_rn
        FROM precio_producto pp
    )
    SELECT 
        p.id AS producto_id,
        p.descripcion AS producto_descripcion,
        c.nombre AS categoria_nombre,
        m.nombre AS marca_nombre,
        m.descripcion_marca AS marca_descripcion,
        uc.uc_costo AS ultimo_costo,
        up.up_precio AS ultimo_precio,
        p.estado AS producto_estado
    FROM producto p
    JOIN categoria c ON p.id_categoria = c.id
    JOIN marca m ON p.id_marca = m.id
    LEFT JOIN ultimo_costo uc ON p.id = uc.uc_id_producto AND uc.uc_rn = 1
    LEFT JOIN ultimo_precio up ON p.id = up.up_id_producto AND up.up_rn = 1
    WHERE p.id = p_id_producto AND p.estado != 'eliminado';
END;
$$;
 A   DROP FUNCTION public.get_producto_activo(p_id_producto integer);
       public               postgres    false                       1255    19407    get_producto_todo(integer)    FUNCTION     `  CREATE FUNCTION public.get_producto_todo(p_id_producto integer) RETURNS TABLE(id integer, descripcion character varying, categoria character varying, marca character varying, descripcion_marca character varying, costo numeric, precio numeric, estado character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH ultimo_costo AS (
        SELECT 
            cp.id_producto AS cp_producto_id,
            cp.costo AS cp_precio_costo,
            ROW_NUMBER() OVER (PARTITION BY cp.id_producto ORDER BY cp.fecha DESC) AS cp_orden
        FROM costo_producto cp
    ),
    ultimo_precio AS (
        SELECT 
            pp.id_producto AS pp_producto_id,
            pp.precio AS pp_precio_venta,
            ROW_NUMBER() OVER (PARTITION BY pp.id_producto ORDER BY pp.fecha DESC) AS pp_orden
        FROM precio_producto pp
    )
    SELECT 
        p.id,
        p.descripcion,
        c.nombre AS categoria,
        m.nombre AS marca,
        m.descripcion_marca,
        uc.cp_precio_costo AS costo,
        up.pp_precio_venta AS precio,
        p.estado
    FROM producto p
    JOIN categoria c ON p.id_categoria = c.id
    JOIN marca m ON p.id_marca = m.id
    LEFT JOIN ultimo_costo uc ON p.id = uc.cp_producto_id AND uc.cp_orden = 1
    LEFT JOIN ultimo_precio up ON p.id = up.pp_producto_id AND up.pp_orden = 1
    WHERE p.id = p_id_producto;
END;
$$;
 ?   DROP FUNCTION public.get_producto_todo(p_id_producto integer);
       public               postgres    false            1           1255    19404    get_productos_activos()    FUNCTION     k  CREATE FUNCTION public.get_productos_activos() RETURNS TABLE(id integer, descripcion character varying, categoria character varying, marca character varying, descripcion_marca character varying, costo numeric, precio numeric, estado character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH costo_actual AS (
        SELECT DISTINCT ON (cp.id_producto)
            cp.id_producto AS cp_id_producto,
            cp.costo AS cp_costo
        FROM costo_producto cp
        ORDER BY cp.id_producto, cp.fecha DESC
    ),
    precio_actual AS (
        SELECT DISTINCT ON (pp.id_producto)
            pp.id_producto AS pp_id_producto,
            pp.precio AS pp_precio
        FROM precio_producto pp
        ORDER BY pp.id_producto, pp.fecha DESC
    )
    SELECT 
        p.id AS producto_id,
        p.descripcion AS producto_descripcion,
        c.nombre AS categoria_nombre,
        m.nombre AS marca_nombre,
        m.descripcion_marca AS marca_descripcion,
        ca.cp_costo AS producto_costo,
        pa.pp_precio AS producto_precio,
        p.estado AS producto_estado
    FROM producto p
    JOIN categoria c ON p.id_categoria = c.id
    JOIN marca m ON p.id_marca = m.id
    LEFT JOIN costo_actual ca ON p.id = ca.cp_id_producto
    LEFT JOIN precio_actual pa ON p.id = pa.pp_id_producto
    WHERE p.estado <> 'eliminado'
    ORDER BY p.id ASC;
END;
$$;
 .   DROP FUNCTION public.get_productos_activos();
       public               postgres    false                       1255    19405    get_productos_todo()    FUNCTION     �  CREATE FUNCTION public.get_productos_todo() RETURNS TABLE(id integer, descripcion character varying, categoria character varying, marca character varying, descripcion_marca character varying, costo numeric, precio numeric, estado character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH ultimos_costos AS (
        SELECT 
            cp.id_producto,
            cp.costo,
            ROW_NUMBER() OVER (PARTITION BY cp.id_producto ORDER BY cp.fecha DESC) AS rn
        FROM costo_producto cp
    ),
    ultimos_precios AS (
        SELECT 
            pp.id_producto,
            pp.precio,
            ROW_NUMBER() OVER (PARTITION BY pp.id_producto ORDER BY pp.fecha DESC) AS rn
        FROM precio_producto pp
    )
    SELECT 
        p.id AS id_producto,
        p.descripcion,
        c.nombre AS categoria,
        m.nombre AS marca,
        m.descripcion_marca,
        uc.costo,
        up.precio AS precio_venta,
        p.estado AS estado_producto
    FROM producto p
    JOIN categoria c ON p.id_categoria = c.id
    JOIN marca m ON p.id_marca = m.id
    LEFT JOIN ultimos_costos uc ON uc.id_producto = p.id AND uc.rn = 1
    LEFT JOIN ultimos_precios up ON up.id_producto = p.id AND up.rn = 1
    ORDER BY p.id ASC;
END;
$$;
 +   DROP FUNCTION public.get_productos_todo();
       public               postgres    false            (           1255    19479 P   insertar_actualizar_detalle_carrito(integer, integer, integer, numeric, numeric) 	   PROCEDURE     �  CREATE PROCEDURE public.insertar_actualizar_detalle_carrito(IN p_id_carrito integer, IN p_id_producto integer, IN p_cantidad integer, IN p_precio_unitario numeric, IN p_subtotal numeric)
    LANGUAGE plpgsql
    AS $$
DECLARE
  detalle_id INT;
BEGIN
  -- Buscar si ya existe el producto en el carrito
  SELECT id INTO detalle_id
  FROM detalle_carrito
  WHERE id_carrito = p_id_carrito AND id_producto = p_id_producto
  LIMIT 1;

  -- Si existe, actualizar cantidad, precio_unitario y subtotal
  IF detalle_id IS NOT NULL THEN
    UPDATE detalle_carrito
    SET 
      cantidad = p_cantidad,
      precio_unitario = p_precio_unitario,
      subtotal = p_subtotal
    WHERE id = detalle_id;
  ELSE
    -- Si no existe, insertar nuevo detalle
    INSERT INTO detalle_carrito (
      id_carrito,
      id_producto,
      cantidad,
      precio_unitario,
      subtotal
    ) VALUES (
      p_id_carrito,
      p_id_producto,
      p_cantidad,
      p_precio_unitario,
      p_subtotal
    );
  END IF;
END;
$$;
 �   DROP PROCEDURE public.insertar_actualizar_detalle_carrito(IN p_id_carrito integer, IN p_id_producto integer, IN p_cantidad integer, IN p_precio_unitario numeric, IN p_subtotal numeric);
       public               postgres    false                       1255    19472 ?   insertar_actualizar_imagen_producto(integer, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.insertar_actualizar_imagen_producto(IN p_id_producto integer, IN p_url character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verificamos que el producto exista
    IF EXISTS (SELECT 1 FROM producto WHERE id = p_id_producto) THEN

        -- Si ya hay una imagen para este producto, actualizamos
        IF EXISTS (SELECT 1 FROM imagen_producto WHERE id_producto = p_id_producto) THEN
            UPDATE imagen_producto
            SET url = p_url
            WHERE id_producto = p_id_producto;
            
            RAISE NOTICE 'Imagen actualizada para el producto ID %', p_id_producto;
        ELSE
            -- Si no hay imagen, insertamos
            INSERT INTO imagen_producto(id_producto, url)
            VALUES (p_id_producto, p_url);
            
            RAISE NOTICE 'Imagen insertada para el producto ID %', p_id_producto;
        END IF;

    ELSE
        RAISE EXCEPTION 'El producto con ID % no existe.', p_id_producto;
    END IF;
END;
$$;
 q   DROP PROCEDURE public.insertar_actualizar_imagen_producto(IN p_id_producto integer, IN p_url character varying);
       public               postgres    false            3           1255    19527 >   insertar_actualizar_imagen_usuario(integer, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.insertar_actualizar_imagen_usuario(IN p_id_usuario integer, IN p_url character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verificamos que el usuario exista
    IF EXISTS (SELECT 1 FROM usuario WHERE id = p_id_usuario) THEN

        -- Si ya hay una imagen para este usuario, actualizamos
        IF EXISTS (SELECT 1 FROM imagen_Usuarios WHERE id_usuario = p_id_usuario) THEN
            UPDATE imagen_Usuarios
            SET url = p_url
            WHERE id_usuario = p_id_usuario;
            
            RAISE NOTICE 'Imagen actualizada para el usuario ID %', p_id_usuario;
        ELSE
            -- Si no hay imagen, insertamos
            INSERT INTO imagen_Usuarios(id_usuario, url)
            VALUES (p_id_usuario, p_url);
            
            RAISE NOTICE 'Imagen insertada para el usuario ID %', p_id_usuario;
        END IF;

    ELSE
        RAISE EXCEPTION 'El usuario con ID % no existe.', p_id_usuario;
    END IF;
END;
$$;
 o   DROP PROCEDURE public.insertar_actualizar_imagen_usuario(IN p_id_usuario integer, IN p_url character varying);
       public               postgres    false            &           1255    19445 B   insertar_inventario(integer, integer, timestamp without time zone) 	   PROCEDURE     d  CREATE PROCEDURE public.insertar_inventario(IN p_id_producto integer, IN p_cantidad integer, IN p_fecha timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verificar si el producto existe
    IF NOT EXISTS (SELECT 1 FROM producto WHERE id = p_id_producto) THEN
        RAISE EXCEPTION 'No existe el producto con ID %', p_id_producto;
    END IF;

    -- Insertar el nuevo inventario
    INSERT INTO inventario(id_producto, cantidad, fecha)
    VALUES (p_id_producto, p_cantidad, p_fecha);

    RAISE NOTICE 'Inventario insertado correctamente para el producto ID %', p_id_producto;
END;
$$;
 �   DROP PROCEDURE public.insertar_inventario(IN p_id_producto integer, IN p_cantidad integer, IN p_fecha timestamp without time zone);
       public               postgres    false            '           1255    19457 ?   insertar_inventario(integer, integer, timestamp with time zone) 	   PROCEDURE     a  CREATE PROCEDURE public.insertar_inventario(IN p_id_producto integer, IN p_cantidad integer, IN p_fecha timestamp with time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verificar si el producto existe
    IF NOT EXISTS (SELECT 1 FROM producto WHERE id = p_id_producto) THEN
        RAISE EXCEPTION 'No existe el producto con ID %', p_id_producto;
    END IF;

    -- Insertar el nuevo inventario
    INSERT INTO inventario(id_producto, cantidad, fecha)
    VALUES (p_id_producto, p_cantidad, p_fecha);

    RAISE NOTICE 'Inventario insertado correctamente para el producto ID %', p_id_producto;
END;
$$;
 �   DROP PROCEDURE public.insertar_inventario(IN p_id_producto integer, IN p_cantidad integer, IN p_fecha timestamp with time zone);
       public               postgres    false            )           1255    19478 H   insertar_o_actualizar_carrito(integer, numeric, date, character varying)    FUNCTION       CREATE FUNCTION public.insertar_o_actualizar_carrito(p_id_cliente integer, p_total numeric, p_fecha date, p_estado character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  carrito_id INT;
BEGIN
  -- Buscar carrito activo existente
  SELECT id INTO carrito_id
  FROM carrito
  WHERE id_cliente = p_id_cliente
  LIMIT 1;

  -- Si existe, actualizar
  IF carrito_id IS NOT NULL THEN
    UPDATE carrito
    SET total = p_total,
        fecha = p_fecha,
        estado = p_estado
    WHERE id = carrito_id;
  ELSE
    -- Insertar nuevo carrito
    INSERT INTO carrito (total, fecha, id_cliente, estado)
    VALUES (p_total, p_fecha, p_id_cliente, p_estado)
    RETURNING id INTO carrito_id;
  END IF;

  -- Devolver el ID del carrito resultante
  RETURN carrito_id;
END;
$$;
 �   DROP FUNCTION public.insertar_o_actualizar_carrito(p_id_cliente integer, p_total numeric, p_fecha date, p_estado character varying);
       public               postgres    false                       1255    19436 [   insertar_permisos(character varying, character varying, boolean, boolean, boolean, boolean) 	   PROCEDURE     �  CREATE PROCEDURE public.insertar_permisos(IN p_username character varying, IN p_ventana character varying, IN p_insertar boolean, IN p_editar boolean, IN p_eliminar boolean, IN p_ver boolean)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_usuario INT;
BEGIN
    -- Obtener el id_usuario correspondiente al username
    SELECT id INTO v_id_usuario
    FROM usuario
    WHERE username = p_username;

    -- Verificar si el usuario existe
    IF v_id_usuario IS NULL THEN
        RAISE EXCEPTION 'Usuario no encontrado: %', p_username;
    END IF;

    -- Verificar si ya existen permisos para el usuario en esa ventana
    IF EXISTS (
        SELECT 1 FROM permisos 
        WHERE id_usuario = v_id_usuario AND ventana = p_ventana
    ) THEN
        -- Si existen permisos, actualizarlos
        UPDATE permisos
        SET insertar = p_insertar,
            editar = p_editar,
            eliminar = p_eliminar,
            ver = p_ver
        WHERE id_usuario = v_id_usuario AND ventana = p_ventana;

        RAISE NOTICE 'Permisos actualizados correctamente para el usuario % en la ventana %', p_username, p_ventana;
    ELSE
        -- Si no existen, insertarlos
        INSERT INTO permisos(id_usuario, insertar, editar, eliminar, ver, ventana)
        VALUES (v_id_usuario, p_insertar, p_editar, p_eliminar, p_ver, p_ventana);

        RAISE NOTICE 'Permisos insertados correctamente para el usuario % en la ventana %', p_username, p_ventana;
    END IF;
END;
$$;
 �   DROP PROCEDURE public.insertar_permisos(IN p_username character varying, IN p_ventana character varying, IN p_insertar boolean, IN p_editar boolean, IN p_eliminar boolean, IN p_ver boolean);
       public               postgres    false                       1255    19379 o   insertar_producto(character varying, character varying, character varying, character varying, numeric, numeric) 	   PROCEDURE     �  CREATE PROCEDURE public.insertar_producto(IN p_descripcion character varying, IN p_categoria character varying, IN p_marca character varying, IN p_estado character varying, IN p_precio numeric, IN p_costo numeric)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_categoria INT;
    v_id_marca INT;
    v_id_producto INT;
BEGIN
    -- Buscar ID de la categoría por su nombre
    SELECT id INTO v_id_categoria FROM categoria WHERE nombre = p_categoria;
    IF v_id_categoria IS NULL THEN
        RAISE EXCEPTION 'No se encontró la categoría: %', p_categoria;
    END IF;

    -- Buscar ID de la marca por su nombre
    SELECT id INTO v_id_marca FROM marca WHERE nombre = p_marca;
    IF v_id_marca IS NULL THEN
        RAISE EXCEPTION 'No se encontró la marca: %', p_marca;
    END IF;

    -- Insertar el producto
    INSERT INTO producto (
        descripcion,
        id_marca,
        id_categoria,
        estado
    ) VALUES (
        p_descripcion,
        v_id_marca,
        v_id_categoria,
        p_estado
    ) RETURNING id INTO v_id_producto;

    -- Insertar costo del producto
    INSERT INTO costo_producto (
        id_producto,
        costo,
        fecha
    ) VALUES (
        v_id_producto,
        p_costo,
        CURRENT_DATE
    );

    -- Insertar precio del producto
    INSERT INTO precio_producto (
        id_producto,
        precio,
        fecha
    ) VALUES (
        v_id_producto,
        p_precio,
        CURRENT_DATE
    );
END;
$$;
 �   DROP PROCEDURE public.insertar_producto(IN p_descripcion character varying, IN p_categoria character varying, IN p_marca character varying, IN p_estado character varying, IN p_precio numeric, IN p_costo numeric);
       public               postgres    false            *           1255    19481     obtener_carrito_cliente(integer)    FUNCTION     U  CREATE FUNCTION public.obtener_carrito_cliente(p_id_cliente integer) RETURNS TABLE(id_carrito integer, total numeric, fecha date, estado character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.total,
    c.fecha,
    c.estado
  FROM carrito c
  WHERE c.id_cliente = p_id_cliente 
  LIMIT 1;
END;
$$;
 D   DROP FUNCTION public.obtener_carrito_cliente(p_id_cliente integer);
       public               postgres    false                       1255    19514 $   obtener_compras_por_cliente(integer)    FUNCTION     �  CREATE FUNCTION public.obtener_compras_por_cliente(p_id_cliente integer) RETURNS TABLE(id_factura integer, fecha date, total numeric, subtotal numeric, descuento numeric, metodo_pago character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.id,
        f.fecha,
        f.total,
        SUM(df.cantidad * df.precio_unitario) AS subtotal,
        SUM(df.cantidad * df.precio_unitario) - f.total AS descuento,
        mp.descripcion AS metodo_pago
    FROM factura f
    JOIN detalle_factura df ON f.id = df.id_factura
    JOIN metodo_pago mp ON f.id_metodo_pago = mp.id
    WHERE f.id_cliente = p_id_cliente
    GROUP BY f.id, f.fecha, f.total, mp.descripcion;
END;
$$;
 H   DROP FUNCTION public.obtener_compras_por_cliente(p_id_cliente integer);
       public               postgres    false                       1255    19496     obtener_detalle_factura(integer)    FUNCTION     �  CREATE FUNCTION public.obtener_detalle_factura(p_id_factura integer) RETURNS TABLE(id_detalle integer, descripcion_producto character varying, cantidad integer, precio_unitario numeric, importe numeric, subtotal numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        df.id,
        p.descripcion,
        df.cantidad,
        df.precio_unitario,
        (df.cantidad * df.precio_unitario) AS importe,
        (
            SELECT SUM(df2.cantidad * df2.precio_unitario)
            FROM detalle_factura df2
            WHERE df2.id_factura = p_id_factura
        ) AS subtotal
    FROM detalle_factura df
    JOIN producto p ON df.id_producto = p.id
    WHERE df.id_factura = p_id_factura;
END;
$$;
 D   DROP FUNCTION public.obtener_detalle_factura(p_id_factura integer);
       public               postgres    false            ,           1255    19485 !   obtener_detalles_carrito(integer)    FUNCTION     �  CREATE FUNCTION public.obtener_detalles_carrito(p_id_carrito integer) RETURNS TABLE(id_detalle integer, id_producto integer, descripcion_producto character varying, cantidad integer, precio_unitario numeric, subtotal numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT 
    dc.id,
    dc.id_producto,
    p.descripcion,
    dc.cantidad,
    dc.precio_unitario,
    dc.subtotal
  FROM detalle_carrito dc
  JOIN producto p ON p.id = dc.id_producto
  WHERE dc.id_carrito = p_id_carrito;
END;
$$;
 E   DROP FUNCTION public.obtener_detalles_carrito(p_id_carrito integer);
       public               postgres    false                       1255    19497    obtener_factura(integer)    FUNCTION     �  CREATE FUNCTION public.obtener_factura(p_id_factura integer) RETURNS TABLE(id_factura integer, nombre_cliente character varying, total numeric, fecha date, metodo_pago character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.id,
        c.nombre_completo,
        f.total,
        f.fecha,
        m.descripcion
    FROM factura f
    JOIN cliente c ON f.id_cliente = c.id
    JOIN metodo_pago m ON f.id_metodo_pago = m.id
    WHERE f.id = p_id_factura;
END;
$$;
 <   DROP FUNCTION public.obtener_factura(p_id_factura integer);
       public               postgres    false                       1255    19494    obtener_facturas()    FUNCTION     �  CREATE FUNCTION public.obtener_facturas() RETURNS TABLE(id_factura integer, nombre_cliente character varying, total numeric, fecha date, metodo_pago character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.id,
        c.nombre_completo,
        f.total,
        f.fecha,
        m.descripcion
    FROM factura f
    JOIN cliente c ON f.id_cliente = c.id
    JOIN metodo_pago m ON f.id_metodo_pago = m.id;
END;
$$;
 )   DROP FUNCTION public.obtener_facturas();
       public               postgres    false            -           1255    19486 "   obtener_ultimo_inventario(integer)    FUNCTION     w  CREATE FUNCTION public.obtener_ultimo_inventario(p_id_producto integer) RETURNS TABLE(id_inventario integer, fecha timestamp without time zone, cantidad integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT 
    i.id_inventario,
    i.fecha,
    i.cantidad
  FROM inventario i
  WHERE i.id_producto = p_id_producto
  ORDER BY i.fecha DESC
  LIMIT 1;
END;
$$;
 G   DROP FUNCTION public.obtener_ultimo_inventario(p_id_producto integer);
       public               postgres    false                       1255    19473    obtener_url_producto(integer)    FUNCTION     �  CREATE FUNCTION public.obtener_url_producto(p_id_producto integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_url TEXT;
BEGIN
    -- Intentamos obtener la URL de la imagen para el producto
    SELECT url INTO v_url
    FROM imagen_producto
    WHERE id_producto = p_id_producto
    LIMIT 1;

    -- Si no se encuentra ninguna imagen, devolvemos NULL
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    RETURN v_url;
END;
$$;
 B   DROP FUNCTION public.obtener_url_producto(p_id_producto integer);
       public               postgres    false            4           1255    19528    obtener_url_usuario(integer)    FUNCTION     �  CREATE FUNCTION public.obtener_url_usuario(p_id_usuario integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_url TEXT;
BEGIN
    -- Intentamos obtener la URL de la imagen para el usuario
    SELECT url INTO v_url
    FROM imagen_Usuarios
    WHERE id_usuario = p_id_usuario
    LIMIT 1;

    -- Si no se encuentra ninguna imagen, devolvemos NULL
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    RETURN v_url;
END;
$$;
 @   DROP FUNCTION public.obtener_url_usuario(p_id_usuario integer);
       public               postgres    false            "           1255    19409     obtener_username_por_email(text)    FUNCTION     x  CREATE FUNCTION public.obtener_username_por_email(p_email text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_username TEXT;
BEGIN
    SELECT username INTO v_username
    FROM usuario
    WHERE email = p_email;

    IF v_username IS NULL THEN
        RAISE EXCEPTION 'No existe un usuario con ese correo electrónico';
    END IF;

    RETURN v_username;
END;
$$;
 ?   DROP FUNCTION public.obtener_username_por_email(p_email text);
       public               postgres    false                       1255    19325 p   registrar_cliente(character varying, character varying, character varying, character varying, character varying) 	   PROCEDURE     #  CREATE PROCEDURE public.registrar_cliente(IN p_nombre_completo character varying, IN p_direccion character varying, IN p_telefono character varying, IN p_estado character varying, IN p_username character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_usuario INT;
BEGIN
    -- Buscar el id del usuario a partir del username
    SELECT id INTO v_id_usuario FROM usuario WHERE username = p_username;

    -- Verificar si se encontró el usuario
    IF v_id_usuario IS NULL THEN
        RAISE EXCEPTION 'No se encontró un usuario con el username: %', p_username;
    END IF;

    -- Verificar si el usuario ya está vinculado a un cliente
    IF EXISTS (SELECT 1 FROM cliente WHERE id_usuario = v_id_usuario) THEN
        RAISE EXCEPTION 'El usuario con username "%" ya está vinculado a un cliente.', p_username;
    END IF;

    -- Verificar si el usuario ya está vinculado a un empleado
    IF EXISTS (SELECT 1 FROM empleado WHERE id_usuario = v_id_usuario) THEN
        RAISE EXCEPTION 'El usuario con username "%" ya está vinculado a un empleado.', p_username;
    END IF;

    -- Insertar el cliente con el id_usuario obtenido
    INSERT INTO cliente(nombre_completo, direccion, telefono, id_usuario, estado)
    VALUES (p_nombre_completo, p_direccion, p_telefono, v_id_usuario, p_estado);
END;
$$;
 �   DROP PROCEDURE public.registrar_cliente(IN p_nombre_completo character varying, IN p_direccion character varying, IN p_telefono character varying, IN p_estado character varying, IN p_username character varying);
       public               postgres    false                       1255    19328 �   registrar_empleado(character varying, character varying, character varying, character varying, date, character varying, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.registrar_empleado(IN p_nombre_completo character varying, IN p_direccion character varying, IN p_telefono character varying, IN p_rol character varying, IN p_fecha_nacimiento date, IN p_estado character varying, IN p_username character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_usuario INT;
BEGIN
    -- Buscar el ID del usuario a partir del username
    SELECT id INTO v_id_usuario
    FROM usuario
    WHERE username = p_username;

    -- Verificar si se encontró el usuario
    IF v_id_usuario IS NULL THEN
        RAISE EXCEPTION 'No se encontró un usuario con el username: %', p_username;
    END IF;

    -- Verificar si el usuario ya está vinculado a un cliente
    IF EXISTS (SELECT 1 FROM cliente WHERE id_usuario = v_id_usuario) THEN
        RAISE EXCEPTION 'El usuario con username "%" ya está vinculado a un cliente.', p_username;
    END IF;

    -- Verificar si el usuario ya está vinculado a un empleado
    IF EXISTS (SELECT 1 FROM empleado WHERE id_usuario = v_id_usuario) THEN
        RAISE EXCEPTION 'El usuario con username "%" ya está vinculado a un empleado.', p_username;
    END IF;

    -- Insertar el nuevo empleado
    INSERT INTO empleado (
        nombre_completo,
        direccion,
        telefono,
        rol,
        fecha_nacimiento,
        id_usuario,
        estado
    ) VALUES (
        p_nombre_completo,
        p_direccion,
        p_telefono,
        p_rol,
        p_fecha_nacimiento,
        v_id_usuario,
        p_estado
    );
END;
$$;
   DROP PROCEDURE public.registrar_empleado(IN p_nombre_completo character varying, IN p_direccion character varying, IN p_telefono character varying, IN p_rol character varying, IN p_fecha_nacimiento date, IN p_estado character varying, IN p_username character varying);
       public               postgres    false            �            1259    18997    carrito    TABLE     �   CREATE TABLE public.carrito (
    id integer NOT NULL,
    total numeric(10,2),
    fecha date,
    id_cliente integer,
    estado character varying(20)
);
    DROP TABLE public.carrito;
       public         heap r       postgres    false            �            1259    18996    carrito_id_seq    SEQUENCE     �   ALTER TABLE public.carrito ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.carrito_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    230            �            1259    18609 	   categoria    TABLE     ^   CREATE TABLE public.categoria (
    id integer NOT NULL,
    nombre character varying(100)
);
    DROP TABLE public.categoria;
       public         heap r       postgres    false            �            1259    18608    categoria_id_seq    SEQUENCE     �   ALTER TABLE public.categoria ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.categoria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    218            �            1259    18986    cliente    TABLE     �   CREATE TABLE public.cliente (
    id integer NOT NULL,
    nombre_completo character varying(100),
    direccion character varying(255),
    telefono character varying(15),
    id_usuario integer,
    estado character varying(20)
);
    DROP TABLE public.cliente;
       public         heap r       postgres    false            �            1259    18985    cliente_id_seq    SEQUENCE     �   ALTER TABLE public.cliente ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cliente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    228            �            1259    19331    codigoverificacion    TABLE     �   CREATE TABLE public.codigoverificacion (
    codigo character varying(5) NOT NULL,
    expiracion timestamp without time zone NOT NULL,
    usado boolean DEFAULT false
);
 &   DROP TABLE public.codigoverificacion;
       public         heap r       postgres    false            �            1259    19386    costo_producto    TABLE     �   CREATE TABLE public.costo_producto (
    id integer NOT NULL,
    id_producto integer,
    costo numeric(10,2),
    fecha date
);
 "   DROP TABLE public.costo_producto;
       public         heap r       postgres    false            �            1259    19385    costo_producto_id_seq    SEQUENCE     �   ALTER TABLE public.costo_producto ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.costo_producto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    245            �            1259    19008    detalle_carrito    TABLE     �   CREATE TABLE public.detalle_carrito (
    id integer NOT NULL,
    cantidad integer,
    precio_unitario numeric(10,2),
    subtotal numeric(10,2),
    id_carrito integer,
    id_producto integer
);
 #   DROP TABLE public.detalle_carrito;
       public         heap r       postgres    false            �            1259    19007    detalle_carrito_id_seq    SEQUENCE     �   ALTER TABLE public.detalle_carrito ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.detalle_carrito_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    232            �            1259    19040    detalle_factura    TABLE     �   CREATE TABLE public.detalle_factura (
    id integer NOT NULL,
    id_factura integer,
    id_producto integer,
    cantidad integer,
    precio_unitario numeric(10,2)
);
 #   DROP TABLE public.detalle_factura;
       public         heap r       postgres    false            �            1259    19039    detalle_factura_id_seq    SEQUENCE     �   ALTER TABLE public.detalle_factura ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.detalle_factura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    236            �            1259    19304    django_migrations    TABLE     �   CREATE TABLE public.django_migrations (
    id bigint NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);
 %   DROP TABLE public.django_migrations;
       public         heap r       postgres    false            �            1259    19303    django_migrations_id_seq    SEQUENCE     �   ALTER TABLE public.django_migrations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    238            �            1259    19314    empleado    TABLE     %  CREATE TABLE public.empleado (
    id integer NOT NULL,
    nombre_completo character varying(100),
    direccion character varying(255),
    telefono character varying(15),
    rol character varying(100),
    fecha_nacimiento date,
    id_usuario integer,
    estado character varying(20)
);
    DROP TABLE public.empleado;
       public         heap r       postgres    false            �            1259    19313    empleado_id_seq    SEQUENCE     �   ALTER TABLE public.empleado ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.empleado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    240            �            1259    19024    factura    TABLE     �   CREATE TABLE public.factura (
    id integer NOT NULL,
    fecha date NOT NULL,
    id_cliente integer,
    total numeric(10,2),
    id_metodo_pago integer,
    estado character varying(20)
);
    DROP TABLE public.factura;
       public         heap r       postgres    false            �            1259    19023    factura_id_seq    SEQUENCE     �   ALTER TABLE public.factura ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.factura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    234            �            1259    19462    imagen_producto    TABLE     z   CREATE TABLE public.imagen_producto (
    id integer NOT NULL,
    id_producto integer,
    url character varying(100)
);
 #   DROP TABLE public.imagen_producto;
       public         heap r       postgres    false            �            1259    19461    imagen_producto_id_seq    SEQUENCE     �   ALTER TABLE public.imagen_producto ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.imagen_producto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    251            �            1259    19517    imagen_usuarios    TABLE     y   CREATE TABLE public.imagen_usuarios (
    id integer NOT NULL,
    id_usuario integer,
    url character varying(100)
);
 #   DROP TABLE public.imagen_usuarios;
       public         heap r       postgres    false            �            1259    19516    imagen_usuarios_id_seq    SEQUENCE     �   ALTER TABLE public.imagen_usuarios ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.imagen_usuarios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    253            �            1259    19447 
   inventario    TABLE     �   CREATE TABLE public.inventario (
    id_inventario integer NOT NULL,
    id_producto integer,
    fecha timestamp without time zone,
    cantidad integer
);
    DROP TABLE public.inventario;
       public         heap r       postgres    false            �            1259    19446    inventario_id_inventario_seq    SEQUENCE     �   ALTER TABLE public.inventario ALTER COLUMN id_inventario ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.inventario_id_inventario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    249            �            1259    18939    marca    TABLE     �   CREATE TABLE public.marca (
    id integer NOT NULL,
    nombre character varying(100),
    descripcion_marca character varying(100)
);
    DROP TABLE public.marca;
       public         heap r       postgres    false            �            1259    18938    marca_id_seq    SEQUENCE     �   ALTER TABLE public.marca ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.marca_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    220            �            1259    18972    metodo_pago    TABLE     e   CREATE TABLE public.metodo_pago (
    id integer NOT NULL,
    descripcion character varying(100)
);
    DROP TABLE public.metodo_pago;
       public         heap r       postgres    false            �            1259    18971    metodo_pago_id_seq    SEQUENCE     �   ALTER TABLE public.metodo_pago ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.metodo_pago_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    224            �            1259    19425    permisos    TABLE     �   CREATE TABLE public.permisos (
    id_permiso integer NOT NULL,
    id_usuario integer,
    insertar boolean,
    editar boolean,
    eliminar boolean,
    ver boolean,
    ventana character varying(100)
);
    DROP TABLE public.permisos;
       public         heap r       postgres    false            �            1259    19424    permisos_id_permiso_seq    SEQUENCE     �   ALTER TABLE public.permisos ALTER COLUMN id_permiso ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.permisos_id_permiso_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    247            �            1259    19369    precio_producto    TABLE     �   CREATE TABLE public.precio_producto (
    id integer NOT NULL,
    id_producto integer,
    precio numeric(10,2),
    fecha date
);
 #   DROP TABLE public.precio_producto;
       public         heap r       postgres    false            �            1259    19368    precio_producto_id_seq    SEQUENCE     �   ALTER TABLE public.precio_producto ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.precio_producto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    243            �            1259    18945    producto    TABLE     �   CREATE TABLE public.producto (
    id integer NOT NULL,
    descripcion character varying(100),
    id_marca integer,
    id_categoria integer,
    estado character varying(20)
);
    DROP TABLE public.producto;
       public         heap r       postgres    false            �            1259    18944    producto_id_seq    SEQUENCE     �   ALTER TABLE public.producto ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.producto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    222            �            1259    18978    usuario    TABLE     �   CREATE TABLE public.usuario (
    id integer NOT NULL,
    username character varying(50),
    password character varying(255),
    email character varying(255),
    tipo_usuario character varying(20),
    estado character varying(20)
);
    DROP TABLE public.usuario;
       public         heap r       postgres    false            �            1259    18977    usuario_id_seq    SEQUENCE     �   ALTER TABLE public.usuario ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    226                      0    18997    carrito 
   TABLE DATA           G   COPY public.carrito (id, total, fecha, id_cliente, estado) FROM stdin;
    public               postgres    false    230   �H      s          0    18609 	   categoria 
   TABLE DATA           /   COPY public.categoria (id, nombre) FROM stdin;
    public               postgres    false    218   �H      }          0    18986    cliente 
   TABLE DATA           _   COPY public.cliente (id, nombre_completo, direccion, telefono, id_usuario, estado) FROM stdin;
    public               postgres    false    228   �H      �          0    19331    codigoverificacion 
   TABLE DATA           G   COPY public.codigoverificacion (codigo, expiracion, usado) FROM stdin;
    public               postgres    false    241   +I      �          0    19386    costo_producto 
   TABLE DATA           G   COPY public.costo_producto (id, id_producto, costo, fecha) FROM stdin;
    public               postgres    false    245   �I      �          0    19008    detalle_carrito 
   TABLE DATA           k   COPY public.detalle_carrito (id, cantidad, precio_unitario, subtotal, id_carrito, id_producto) FROM stdin;
    public               postgres    false    232   J      �          0    19040    detalle_factura 
   TABLE DATA           a   COPY public.detalle_factura (id, id_factura, id_producto, cantidad, precio_unitario) FROM stdin;
    public               postgres    false    236   ;J      �          0    19304    django_migrations 
   TABLE DATA           C   COPY public.django_migrations (id, app, name, applied) FROM stdin;
    public               postgres    false    238   �J      �          0    19314    empleado 
   TABLE DATA           w   COPY public.empleado (id, nombre_completo, direccion, telefono, rol, fecha_nacimiento, id_usuario, estado) FROM stdin;
    public               postgres    false    240   .L      �          0    19024    factura 
   TABLE DATA           W   COPY public.factura (id, fecha, id_cliente, total, id_metodo_pago, estado) FROM stdin;
    public               postgres    false    234   �L      �          0    19462    imagen_producto 
   TABLE DATA           ?   COPY public.imagen_producto (id, id_producto, url) FROM stdin;
    public               postgres    false    251   /M      �          0    19517    imagen_usuarios 
   TABLE DATA           >   COPY public.imagen_usuarios (id, id_usuario, url) FROM stdin;
    public               postgres    false    253   �M      �          0    19447 
   inventario 
   TABLE DATA           Q   COPY public.inventario (id_inventario, id_producto, fecha, cantidad) FROM stdin;
    public               postgres    false    249   N      u          0    18939    marca 
   TABLE DATA           >   COPY public.marca (id, nombre, descripcion_marca) FROM stdin;
    public               postgres    false    220   dN      y          0    18972    metodo_pago 
   TABLE DATA           6   COPY public.metodo_pago (id, descripcion) FROM stdin;
    public               postgres    false    224   �N      �          0    19425    permisos 
   TABLE DATA           d   COPY public.permisos (id_permiso, id_usuario, insertar, editar, eliminar, ver, ventana) FROM stdin;
    public               postgres    false    247   �N      �          0    19369    precio_producto 
   TABLE DATA           I   COPY public.precio_producto (id, id_producto, precio, fecha) FROM stdin;
    public               postgres    false    243   IO      w          0    18945    producto 
   TABLE DATA           S   COPY public.producto (id, descripcion, id_marca, id_categoria, estado) FROM stdin;
    public               postgres    false    222   �O      {          0    18978    usuario 
   TABLE DATA           V   COPY public.usuario (id, username, password, email, tipo_usuario, estado) FROM stdin;
    public               postgres    false    226   P      �           0    0    carrito_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.carrito_id_seq', 17, true);
          public               postgres    false    229            �           0    0    categoria_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.categoria_id_seq', 6, true);
          public               postgres    false    217            �           0    0    cliente_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.cliente_id_seq', 1, true);
          public               postgres    false    227            �           0    0    costo_producto_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.costo_producto_id_seq', 6, true);
          public               postgres    false    244            �           0    0    detalle_carrito_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.detalle_carrito_id_seq', 30, true);
          public               postgres    false    231            �           0    0    detalle_factura_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.detalle_factura_id_seq', 12, true);
          public               postgres    false    235            �           0    0    django_migrations_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.django_migrations_id_seq', 19, true);
          public               postgres    false    237            �           0    0    empleado_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.empleado_id_seq', 3, true);
          public               postgres    false    239            �           0    0    factura_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.factura_id_seq', 12, true);
          public               postgres    false    233            �           0    0    imagen_producto_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.imagen_producto_id_seq', 2, true);
          public               postgres    false    250            �           0    0    imagen_usuarios_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.imagen_usuarios_id_seq', 1, true);
          public               postgres    false    252            �           0    0    inventario_id_inventario_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.inventario_id_inventario_seq', 30, true);
          public               postgres    false    248            �           0    0    marca_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.marca_id_seq', 4, true);
          public               postgres    false    219            �           0    0    metodo_pago_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.metodo_pago_id_seq', 3, true);
          public               postgres    false    223            �           0    0    permisos_id_permiso_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.permisos_id_permiso_seq', 5, true);
          public               postgres    false    246            �           0    0    precio_producto_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.precio_producto_id_seq', 6, true);
          public               postgres    false    242            �           0    0    producto_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.producto_id_seq', 6, true);
          public               postgres    false    221            �           0    0    usuario_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.usuario_id_seq', 8, true);
          public               postgres    false    225            �           2606    19001    carrito carrito_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.carrito
    ADD CONSTRAINT carrito_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.carrito DROP CONSTRAINT carrito_pkey;
       public                 postgres    false    230            �           2606    18613    categoria categoria_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.categoria DROP CONSTRAINT categoria_pkey;
       public                 postgres    false    218            �           2606    18990    cliente cliente_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.cliente DROP CONSTRAINT cliente_pkey;
       public                 postgres    false    228            �           2606    19336 *   codigoverificacion codigoverificacion_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.codigoverificacion
    ADD CONSTRAINT codigoverificacion_pkey PRIMARY KEY (codigo);
 T   ALTER TABLE ONLY public.codigoverificacion DROP CONSTRAINT codigoverificacion_pkey;
       public                 postgres    false    241            �           2606    19390 "   costo_producto costo_producto_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.costo_producto
    ADD CONSTRAINT costo_producto_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.costo_producto DROP CONSTRAINT costo_producto_pkey;
       public                 postgres    false    245            �           2606    19012 $   detalle_carrito detalle_carrito_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.detalle_carrito
    ADD CONSTRAINT detalle_carrito_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.detalle_carrito DROP CONSTRAINT detalle_carrito_pkey;
       public                 postgres    false    232            �           2606    19044 $   detalle_factura detalle_factura_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.detalle_factura
    ADD CONSTRAINT detalle_factura_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.detalle_factura DROP CONSTRAINT detalle_factura_pkey;
       public                 postgres    false    236            �           2606    19310 (   django_migrations django_migrations_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.django_migrations DROP CONSTRAINT django_migrations_pkey;
       public                 postgres    false    238            �           2606    19318    empleado empleado_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.empleado
    ADD CONSTRAINT empleado_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.empleado DROP CONSTRAINT empleado_pkey;
       public                 postgres    false    240            �           2606    19028    factura factura_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.factura DROP CONSTRAINT factura_pkey;
       public                 postgres    false    234            �           2606    19466 $   imagen_producto imagen_producto_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.imagen_producto
    ADD CONSTRAINT imagen_producto_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.imagen_producto DROP CONSTRAINT imagen_producto_pkey;
       public                 postgres    false    251            �           2606    19521 $   imagen_usuarios imagen_usuarios_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.imagen_usuarios
    ADD CONSTRAINT imagen_usuarios_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.imagen_usuarios DROP CONSTRAINT imagen_usuarios_pkey;
       public                 postgres    false    253            �           2606    19451    inventario inventario_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.inventario
    ADD CONSTRAINT inventario_pkey PRIMARY KEY (id_inventario);
 D   ALTER TABLE ONLY public.inventario DROP CONSTRAINT inventario_pkey;
       public                 postgres    false    249            �           2606    18943    marca marca_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.marca
    ADD CONSTRAINT marca_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.marca DROP CONSTRAINT marca_pkey;
       public                 postgres    false    220            �           2606    18976    metodo_pago metodo_pago_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.metodo_pago
    ADD CONSTRAINT metodo_pago_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.metodo_pago DROP CONSTRAINT metodo_pago_pkey;
       public                 postgres    false    224            �           2606    19429    permisos permisos_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.permisos
    ADD CONSTRAINT permisos_pkey PRIMARY KEY (id_permiso);
 @   ALTER TABLE ONLY public.permisos DROP CONSTRAINT permisos_pkey;
       public                 postgres    false    247            �           2606    19373 $   precio_producto precio_producto_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.precio_producto
    ADD CONSTRAINT precio_producto_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.precio_producto DROP CONSTRAINT precio_producto_pkey;
       public                 postgres    false    243            �           2606    18949    producto producto_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.producto
    ADD CONSTRAINT producto_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.producto DROP CONSTRAINT producto_pkey;
       public                 postgres    false    222            �           2606    18984    usuario usuario_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_pkey;
       public                 postgres    false    226            �           2620    19493 /   detalle_factura trg_actualizar_inventario_venta    TRIGGER     �   CREATE TRIGGER trg_actualizar_inventario_venta AFTER INSERT ON public.detalle_factura FOR EACH ROW EXECUTE FUNCTION public.actualizar_inventario_tras_venta();
 H   DROP TRIGGER trg_actualizar_inventario_venta ON public.detalle_factura;
       public               postgres    false    272    236            �           2620    19489 ,   detalle_carrito trg_actualizar_total_carrito    TRIGGER     �   CREATE TRIGGER trg_actualizar_total_carrito AFTER INSERT OR DELETE OR UPDATE ON public.detalle_carrito FOR EACH ROW EXECUTE FUNCTION public.actualizar_total_carrito();
 E   DROP TRIGGER trg_actualizar_total_carrito ON public.detalle_carrito;
       public               postgres    false    303    232            �           2620    19513 +   carrito trigger_eliminar_carrito_finalizado    TRIGGER     �   CREATE TRIGGER trigger_eliminar_carrito_finalizado AFTER UPDATE ON public.carrito FOR EACH ROW EXECUTE FUNCTION public.eliminar_carrito_si_finalizado();
 D   DROP TRIGGER trigger_eliminar_carrito_finalizado ON public.carrito;
       public               postgres    false    304    230            �           2606    19002    carrito carrito_id_cliente_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.carrito
    ADD CONSTRAINT carrito_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id);
 I   ALTER TABLE ONLY public.carrito DROP CONSTRAINT carrito_id_cliente_fkey;
       public               postgres    false    228    230    4786            �           2606    18991    cliente cliente_id_usuario_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id);
 I   ALTER TABLE ONLY public.cliente DROP CONSTRAINT cliente_id_usuario_fkey;
       public               postgres    false    228    4784    226            �           2606    19391 .   costo_producto costo_producto_id_producto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.costo_producto
    ADD CONSTRAINT costo_producto_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES public.producto(id);
 X   ALTER TABLE ONLY public.costo_producto DROP CONSTRAINT costo_producto_id_producto_fkey;
       public               postgres    false    245    4780    222            �           2606    19013 /   detalle_carrito detalle_carrito_id_carrito_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.detalle_carrito
    ADD CONSTRAINT detalle_carrito_id_carrito_fkey FOREIGN KEY (id_carrito) REFERENCES public.carrito(id);
 Y   ALTER TABLE ONLY public.detalle_carrito DROP CONSTRAINT detalle_carrito_id_carrito_fkey;
       public               postgres    false    230    4788    232            �           2606    19018 0   detalle_carrito detalle_carrito_id_producto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.detalle_carrito
    ADD CONSTRAINT detalle_carrito_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES public.producto(id);
 Z   ALTER TABLE ONLY public.detalle_carrito DROP CONSTRAINT detalle_carrito_id_producto_fkey;
       public               postgres    false    232    4780    222            �           2606    19045 /   detalle_factura detalle_factura_id_factura_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.detalle_factura
    ADD CONSTRAINT detalle_factura_id_factura_fkey FOREIGN KEY (id_factura) REFERENCES public.factura(id);
 Y   ALTER TABLE ONLY public.detalle_factura DROP CONSTRAINT detalle_factura_id_factura_fkey;
       public               postgres    false    4792    236    234            �           2606    19050 0   detalle_factura detalle_factura_id_producto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.detalle_factura
    ADD CONSTRAINT detalle_factura_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES public.producto(id);
 Z   ALTER TABLE ONLY public.detalle_factura DROP CONSTRAINT detalle_factura_id_producto_fkey;
       public               postgres    false    4780    222    236            �           2606    19319 !   empleado empleado_id_usuario_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.empleado
    ADD CONSTRAINT empleado_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id);
 K   ALTER TABLE ONLY public.empleado DROP CONSTRAINT empleado_id_usuario_fkey;
       public               postgres    false    226    240    4784            �           2606    19029    factura factura_id_cliente_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id);
 I   ALTER TABLE ONLY public.factura DROP CONSTRAINT factura_id_cliente_fkey;
       public               postgres    false    4786    228    234            �           2606    19034 #   factura factura_id_metodo_pago_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_id_metodo_pago_fkey FOREIGN KEY (id_metodo_pago) REFERENCES public.metodo_pago(id);
 M   ALTER TABLE ONLY public.factura DROP CONSTRAINT factura_id_metodo_pago_fkey;
       public               postgres    false    224    234    4782            �           2606    19467 0   imagen_producto imagen_producto_id_producto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.imagen_producto
    ADD CONSTRAINT imagen_producto_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES public.producto(id);
 Z   ALTER TABLE ONLY public.imagen_producto DROP CONSTRAINT imagen_producto_id_producto_fkey;
       public               postgres    false    222    251    4780            �           2606    19522 /   imagen_usuarios imagen_usuarios_id_usuario_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.imagen_usuarios
    ADD CONSTRAINT imagen_usuarios_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id);
 Y   ALTER TABLE ONLY public.imagen_usuarios DROP CONSTRAINT imagen_usuarios_id_usuario_fkey;
       public               postgres    false    226    253    4784            �           2606    19452 &   inventario inventario_id_producto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.inventario
    ADD CONSTRAINT inventario_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES public.producto(id);
 P   ALTER TABLE ONLY public.inventario DROP CONSTRAINT inventario_id_producto_fkey;
       public               postgres    false    249    222    4780            �           2606    19430 !   permisos permisos_id_usuario_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.permisos
    ADD CONSTRAINT permisos_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id);
 K   ALTER TABLE ONLY public.permisos DROP CONSTRAINT permisos_id_usuario_fkey;
       public               postgres    false    4784    226    247            �           2606    19374 0   precio_producto precio_producto_id_producto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.precio_producto
    ADD CONSTRAINT precio_producto_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES public.producto(id);
 Z   ALTER TABLE ONLY public.precio_producto DROP CONSTRAINT precio_producto_id_producto_fkey;
       public               postgres    false    222    243    4780            �           2606    18955 #   producto producto_id_categoria_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.producto
    ADD CONSTRAINT producto_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.categoria(id);
 M   ALTER TABLE ONLY public.producto DROP CONSTRAINT producto_id_categoria_fkey;
       public               postgres    false    4776    218    222            �           2606    18950    producto producto_id_marca_fkey    FK CONSTRAINT        ALTER TABLE ONLY public.producto
    ADD CONSTRAINT producto_id_marca_fkey FOREIGN KEY (id_marca) REFERENCES public.marca(id);
 I   ALTER TABLE ONLY public.producto DROP CONSTRAINT producto_id_marca_fkey;
       public               postgres    false    4778    222    220                  x������ � �      s   /   x�3��I,(�/�2�tLNN-�/��/�2�tN�)�I,J-����� � �      }   >   x�3�HM)�W�LN,��tN��IU��/V���,�/�43002327�4�LL.
q��qqq �t�      �   �   x�uλ�0��ښ"� �/Q������XI{�p�'k���l��X�K� ����"y#�˒"�L����N�	l�z�GH�n�[U4�%L�e��~�߈-3�ɮ�9���I�,Q�l���X��p�py� I�1��'�1>8�<�      �   C   x�m���0Cѳ�K+ǉ+؅��#�^��~���$Dy�G*�H�������,|��Yo��^{�fD�kx      �      x������ � �      �   V   x�U���0�K1`��K��#`9��@b�e
����0S��$C��N���mnA�y������sO��-�hJz��(D/�S���@      �   }  x���ێ� ���)��p}�M&D�K��rhڷ_4MZS�������Y�G'F���B���\evB�	5_]Ps!�\���*<�Iƽ�9�`1A3�r<))k�H�F(݇B���M@8_��2��9୓z���=�?Z���{VEY9��]�YM܀yF>�TMR����	�0��v�h�����؇�ޓ��`�P4����T�)M�[ʼ,����ةP0F���ŭ���ЙW;3�p,�D)��_/M��h�Y�'�z=�Xʍ+�q��]�/��a-���^�'�&\���'�+�H����?Q��(�z��t>�z��	��OA�����cs#��$F�Θl��Js����xaՙ��Ͽ�5�d�zn�>c���s��]�g�      �   �   x�u̱�  ���
~ s�Z�Ѹ5&݌�)$��~Y���v��Ω�A
�,>f�C�[�i"w���c��	�"`���3���?El�ŵ��=�R*U_Ce��P�.��	�d�5�����A)�}/�      �   a   x��ϻ�@�:م�c.|v�A��
:�� %�͓eSz��b�p@(��ζ��G@��{E���#<�
�G1�9b� ���i���oL;S�����r>�      �   ^   x����  ��Cՠg��@�D���ޭ��B� 75i?.�����e��8 f�����V�l6��P����(`�Ć}��\�B�9J 2      �   ^   x��[@  �o-�{"r��O/D��ݛa�h���k�����b�)s�:0a�\n��r�P�Gi�a��lC��k�S�t`\0'�!�Jw\�L	!?:� q      �   I   x�]���@�7Ta^�]����4�'�me�y2�FX��d�l˟�5����4��_�����r����      u   0   x�3�t�
�A��\F�@����e�鑟�_!�b���� ;Qv      y   4   x�3��2�H�,H��2�)J�+NK-J�K�LTpJ�KN,�L����� "M�      �   Q   x�3�4�L�N�܂��Ĕ�b.c�h	委&� EM�D}���L�D�KR��2��D=��R�J�2�b���� �=�      �   C   x�m̱�0����E��K��#)�����9I�������D��e1ֻhv�5w���3�m�#      w   l   x�3�I�IM���W�w�u���4�4�LL.�,��2��I,(�/PpO�M-RH��S�4UHIU04200PHO�S�4�4�)7�� T�a��i4%5'373/1%�+F��� ��@      {   /  x�}��n�0 ��c��L���D�� N�d)P�
-`ˏW�d�v�x�|ϒ+�tC��kv�?og�O����S��~�b�����.��{M�ˁ�+�O�Ďcb�&v���z���g��g���R�T�i�9�KD�q�J	�U�Q�$�r�2J+&�{���E9�7�bDn�7���6̔c��p=e��'�e{A���X��{P_��^V@�f�'��	���_�.U8k��sp����?YG���]����֢2_��.� �b�z��6����ă�F�������ϐS�	cY�� 6��     