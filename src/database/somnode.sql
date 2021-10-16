-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 16-10-2021 a las 03:02:30
-- Versión del servidor: 8.0.21
-- Versión de PHP: 7.4.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `somnode`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `p_actualizar_cliente` (`dnic` VARCHAR(8), `nombresc` VARCHAR(100), `apePc` VARCHAR(50), `direccionc` VARCHAR(100), `telefonoc` VARCHAR(9))  begin
	select count(*) into @existe from personas where dni=dnic;
    select length(dnic) into @dni; 
    
    if @existe=1 then
		if @dni=8 then
			update personas set nombre=nombresc,apellido=apePc,direccion=direccionc,telefono=telefonoc 
            where dni=dnic;
			
			select 'Se actualizo el cliente correctamente';
		else
			select 'El dni debe tener 8 digitos';
		end if;
	else
		select 'No existe una persona registrada con este dni';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_actualizar_empleado` (IN `dnic` VARCHAR(8), IN `nombresc` VARCHAR(100), IN `apec` VARCHAR(50), IN `direccionc` VARCHAR(100), IN `telefonoc` VARCHAR(9), IN `categoriac` INT, IN `usuc` VARCHAR(45), IN `fotor` TEXT)  begin
	select count(*) into @existe from personas where dni=dnic;
    select length(dnic) into @dni; 
    select count(*) into @existeusu from empleados where login=usuc and fk_dni<>dnic;
    if @existe=1 then
		if @dni=8 then
			if @existeusu=0 then
				UPDATE personas set nombre=nombresc,apellido=apec,direccion=direccionc,telefono=telefonoc where dni=dnic;
				
				update empleados set login=usuc,fk_idCategoria=categoriac, foto=fotor where fk_dni=dnic;
				select 'Se actualizo correctamente';
			else
				select 'El usuario ya existe';
			end if;
		else
			select 'El dni debe tener 8 digitos';
		end if;
	else
		select 'No existe una persona registrada con este dni';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_actualizar_plato` (IN `idpl` INT, IN `descrip` VARCHAR(100), IN `prec` DECIMAL(10,2), IN `espe` INT, IN `tipo` INT, IN `fotor` TEXT)  begin
	select count(*) into @existe from platos where descripcion=descrip; 
    
    if @existe=1 then

			update platos set descripcion=descrip,precio=prec,fk_idEspecialidad=espe,fk_tipoPlato=tipo,
            foto=fotor where idPlato=idpl;
	
			select 'Se actualizo el plato correctamente';
	else
		select 'No existe una plato registrado con este id';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_agregar_detalle_plato` (`reser` INT, `plator` INT, `canti` INT)  begin
	declare existe_venta int;
    
    select count(*) into existe_venta from reservas where idReserva=reser;
    
	if existe_venta=1 then
		
			Insert into detalles(cantidad,fk_idReserva,fk_idPlato) 
			values (canti,reser,plator);
			
			select 'Detalle agregado correctamente';
	
	else
		select 'La reserva no existe, usted no puede agregar detalles a ventas ya existentes' ERROR;
	end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_buscar_Cliente` (`busqueda` VARCHAR(50))  begin
	select ID,DNI,CLIENTE,DIRECCION,TELEFONO
	from v_clientes vc
	where ID like concat('%',busqueda,'%')
    or DNI like concat('%',busqueda,'%')
    or CLIENTE like concat('%',busqueda,'%')
    or DIRECCION like concat('%',busqueda,'%')
    or TELEFONO like concat('%',busqueda,'%');
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_buscar_empleados` (`busqueda` VARCHAR(50))  begin
	select ID,DNI,EMPLEADO,DIRECCION,TELEFONO,USUARIO,CATEGORIA
	from v_empleados ve
	where ID like concat('%',busqueda,'%')
    or DNI like concat('%',busqueda,'%')
    or EMPLEADO like concat('%',busqueda,'%')
    or DIRECCION like concat('%',busqueda,'%')
    or TELEFONO like concat('%',busqueda,'%')
    or USUARIO like concat('%',busqueda,'%')
    or CATEGORIA like concat('%',busqueda,'%');
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_buscar_Plato` (`busqueda` VARCHAR(50))  begin
	select ID,PLATO,PRECIO,TIPO,ESPECIALIDAD
	from v_platos 
	where ID like concat('%',busqueda,'%')
    or PLATO like concat('%',busqueda,'%')
    or PRECIO like concat('%',busqueda,'%')
    or TIPO like concat('%',busqueda,'%')
    or ESPECIALIDAD like concat('%',busqueda,'%');
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_crear_reserva` (IN `empleado` INT(15), IN `cliente` INT(15), IN `turno` INT, IN `ncome` INT, IN `fechar` DATE, IN `horai` TIME, IN `horaf` TIME)  begin
	declare existe_empleado int;
    declare existe_cliente int;
SELECT COUNT(*) INTO existe_empleado FROM empleados WHERE idEmpleado = empleado;
SELECT COUNT(*) INTO existe_cliente FROM clientes WHERE idcliente = cliente;
 
 SELECT COUNT(*) into @existemesa FROM mesas m
		where ncome<=m.aforo and not EXISTS (select * from rservaxmesa  r
     where m.idmesa=r.fk_idmesa and r.fecha=fechar and ((r.hora_inicio<=horai and horai<=r.hora_fin) or
 			(r.hora_inicio<=horaf and horaf<=r.hora_fin) or (horai<=r.hora_inicio and r.hora_inicio<=horaf)or (horai<=r.hora_fin and r.hora_fin<=horaf)));
            
    if (existe_empleado=1) then
        if (existe_cliente=1) then
               IF(@existemesa>0)THEN                              
                        SELECT m.idmesa into @mesa FROM mesas m
                        where ncome<=m.aforo and not EXISTS (select * from rservaxmesa  r
                     where m.idmesa=r.fk_idmesa and r.fecha=fechar and ((r.hora_inicio<=horai and horai<=r.hora_fin) or
                            (r.hora_inicio<=horaf and horaf<=r.hora_fin) or (horai<=r.hora_inicio and r.hora_inicio<=horaf)
                         or 		(horai<=r.hora_fin and r.hora_fin<=horaf)))
                     limit 1;

                     insert into reservas(monto,nComensales,fk_idEmpleado,fk_codCliente,fk_idturno,fk_idestados)
                     values ('0.00',ncome,empleado,cliente,turno,4);

                     select MAX(idReserva) into @idrese from reservas;

                     insert into rservaxmesa(fk_idReserva,fk_idmesa,fecha,hora_inicio,hora_fin)
                     values(@idrese,@mesa,fechar,horai,horaf);

                     SELECT 'Reserva guardada con exito';
               else
               		SELECT'No hay mesa disponible';
               end if;
           	else
               SELECT'No existe un cliente con este ID';
     	end if;
        else
              SELECT'No existe un empleado con este ID';
	end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_dar_comprobante` (IN `reser` INT, IN `tipocom` INT)  BEGIN
    	select fk_idestados into @paga from reservas where idReserva =reser;
        select COUNT(*) into @existe from comprobantes where fk_reserva =reser;
        select sum(p.precio*d.cantidad) into @montototal
        	from detalles d
			inner join platos p on p.idPlato=d.fk_idPlato
			where d.fk_idReserva=reser;
        
        if @paga=3 THEN
        	if@existe=0 then
                insert into comprobantes(codComprobante,impuesto,fk_reserva,fk_tipocomprobante)
                values(f_generar_codComprobante(tipocom),@montototal*0.18,reser,tipocom);
                SELECT 'Comprobante generado correctamente';
             ELSE
             	SELECT 'La reserva ya posee un comprobante';
             end if;
        else
        	SELECT 'La reserva no ha sido pagada';
        end if;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_datos_reserva` (`reser` INT)  begin
    select r.idReserva,concat_ws(' ',pe.nombre,pe.apellido) EMPLEADO,concat_ws(' ',pc.nombre,pc.apellido)CLIENTE,
      t.nombreturno,rm.fecha,rm.hora_inicio,rm.hora_fin,rm.fk_idmesa mesa,r.nComensales,r.monto
    from reservas r
    inner join rservaxmesa rm on rm.fk_idReserva=r.idReserva
    inner join empleados e on e.idEmpleado=r.fk_idEmpleado
    inner join clientes c on c.idcliente=r.fk_codCliente
    inner join personas pe on pe.dni=e.fk_dni
    inner join personas pc on pc.dni=c.fk_dni
    inner join turnos t on t.idturno=r.fk_idturno
    inner join estados es on es.idestados=r.fk_idestados
    where r.idReserva=reser;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_eliminar_cliente` (`idc` INT)  begin
	select count(*) into @existe from clientes where idcliente=idc and fk_idestados=1;
    IF @existe=1 then
		update clientes set fk_idestados=2 where idcliente=idc;
		select 'El cliente se elimino correctamente';
	else
		select 'El cliente no existe';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_eliminar_detalle_plato` (`reser` INT, `plator` INT)  begin
	declare existe_venta int;
    
    select count(*) into existe_venta from reservas where idReserva=reser;
    
	if existe_venta=1 then
		
			delete from detalles where fk_idReserva=reser and fk_idPlato=plator;
			
			select 'Detalle eliminado correctamente';
	
	else
		select 'La reserva no existe' ERROR;
	end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_eliminar_empleado` (`id` INT)  begin
	select count(*) into @existe from empleados where idEmpleado=id and fk_idestados=1;
    IF @existe=1 then
		update empleados set fk_idestados=2 where idEmpleado=id;
		select 'El empleado se elimino correctamente';
	else
		select 'El empleado no existe';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_eliminar_plato` (`id` INT)  begin
	select count(*) into @existe from platos where idPlato=id and fk_idestados=1;
    IF @existe=1 then
		update platos set fk_idestados=2 where idPlato=id;
		select 'El plato se elimino correctamente';
	else
		select 'El plato no existe';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_nuevo_cliente` (`dnic` VARCHAR(8), `nombresc` VARCHAR(100), `apePc` VARCHAR(50), `direccionc` VARCHAR(100), `telefonoc` VARCHAR(9))  begin
	select count(*) into @existe from personas where DNI=dnic;
    select length(dnic) into @dni; 
    
    if @existe=0 then
		if @dni=8 then
			insert into personas(dni,nombre,apellido,direccion,telefono)
			values(dnic,nombresc,apePc,direccionc,telefonoc);
			
			insert into clientes(fk_dni,fk_idestados)
			values (dnic,1);
			select 'Se registro el cliente correctamente';
		else
			select 'El dni debe tener 8 digitos';
		end if;
	else
		select 'Ya existe una persona registrada con este dni';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_nuevo_empleado` (IN `dnic` VARCHAR(8), IN `nombresc` VARCHAR(100), IN `apec` VARCHAR(100), IN `direccionc` VARCHAR(100), IN `telefonoc` VARCHAR(9), IN `categoriac` INT, IN `usuc` VARCHAR(45), IN `clavec` VARCHAR(500))  begin
	select count(*) into @existe from personas where dni=dnic;
    select length(dnic) into @dni; 
    select count(*) into @existeusu from empleados where login=usuc;
    if @existe=0 then
		if @dni=8 then
			if @existeusu=0 then
				insert into personas(dni,nombre,apellido,direccion,telefono)
				values(dnic,nombresc,apec,direccionc,telefonoc);
				
				insert into empleados(login,clave,fk_idCategoria,fk_idestados,fk_dni)
				values (usuc,clavec,categoriac,1,dnic);
				select 'Se registro correctamente';
			else
				select 'El usuario ya existe';
			end if;
		else
			select 'El dni debe tener 8 digitos';
		end if;
	else
		select 'Ya existe una persona registrada con este dni';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_nuevo_empleadoo` (IN `dnic` VARCHAR(8), IN `nombresc` VARCHAR(100), IN `apec` VARCHAR(100), IN `direccionc` VARCHAR(100), IN `telefonoc` VARCHAR(9), IN `categoriac` INT, IN `usuc` VARCHAR(45), IN `clavec` VARCHAR(500), IN `fotoem` TEXT)  begin
	select count(*) into @existe from personas where dni=dnic;
    select length(dnic) into @dni; 
    select count(*) into @existeusu from empleados where login=usuc;
    if @existe=0 then
		if @dni=8 then
			if @existeusu=0 then
				insert into personas(dni,nombre,apellido,direccion,telefono)
				values(dnic,nombresc,apec,direccionc,telefonoc);
				
				insert into empleados(login,clave,foto,fk_idCategoria,fk_idestados,fk_dni)
				values (usuc,clavec,fotoem,categoriac,1,dnic);
				select 'Se registro correctamente';
			else
				select 'El usuario ya existe';
			end if;
		else
			select 'El dni debe tener 8 digitos';
		end if;
	else
		select 'Ya existe una persona registrada con este dni';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_nuevo_plato` (IN `descrip` VARCHAR(100), IN `prec` DECIMAL(10,2), IN `espe` INT, IN `tipo` INT, IN `fotop` TEXT)  begin
	select count(*) into @existe from platos where descripcion=descrip; 
    
    if @existe=0 then

			insert into platos(descripcion,precio,fk_idEspecialidad,fk_tipoPlato,fk_idestados, foto)
			values(descrip,prec,espe,tipo,1,fotop);
		
			select 'Se registro el plato correctamente';
	else
		select 'Ya existe una palto registrado con esta descripcion';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_procesar_pago` (IN `reser` INT, IN `montore` DECIMAL(10,2), IN `tipopa` INT)  BEGIN
    	select fk_idestados into @paga from reservas where idReserva =reser;
        select sum(p.precio*d.cantidad) into @montototal
        	from detalles d
			inner join platos p on p.idPlato=d.fk_idPlato
			where d.fk_idReserva=reser;
        
        if @paga=4 THEN
            if @montototal=montore THEN
               	insert into pagos(total_pago,fecha_emision,fk_idReserva,fk_tipopago)
           		values (@montototal,curdate(),reser,tipopa);
            	UPDATE reservas set fk_idestados=3, monto=@montototal where idReserva=reser;
                
                  SELECT 'Pago realizado correctamente';  
                  
            ELSEIF @montototal<montore then
            	insert into pagos(total_pago,fecha_emision,fk_idReserva,fk_tipopago)
           		 values (@montototal,curdate(),reser,tipopa);
            	UPDATE reservas set fk_idestados=3, monto=@montototal where idReserva=reser;
                
            	select montore-@montototal into @vuelto;
                SELECT concat_ws(' ','Pago realizado correctamente, tenga su vuelto: S/.',@vuelto);
                
            ELSEIF @montototal>montore THEN
            	select @montototal-montore into @falta;
                SELECT concat_ws(' ','EEROR, Pago no realizado, falta la cantidad de: S/.',@falta);
            end if;
        else
        	SELECT 'ERROR, La reserva ya ha sido pagada';
        end if;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_ver_detalles` (IN `reser` INT)  begin
	select d.fk_idReserva,p.idPlato, p.descripcion,p.precio,d.cantidad,(p.precio*d.cantidad) SUBTOTAL
        from detalles d
		inner join platos p on p.idPlato=d.fk_idPlato
		where d.fk_idReserva=reser;
  
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `f_generar_codComprobante` (`tipo` INT) RETURNS VARCHAR(8) CHARSET utf8mb4 BEGIN
    DECLARE contador INT;
    declare n varchar(8);
    
    if tipo=1 then
		set n='B0-';
		else if tipo=2 then
			set n='FA-';
		END IF;
    end if;
        SET contador= (SELECT COUNT(*)+1 FROM comprobantes where fk_tipocomprobante=tipo); 
        IF(contador<10)THEN
            SET n= CONCAT(n,'0000',contador);
            ELSE IF(contador<100) THEN
                SET n= CONCAT(n,'000',contador);
                ELSE IF(contador<1000)THEN
                    SET n= CONCAT(n,'00',contador);
                END IF;
            END IF;
        END IF; 
	return n;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `idCategoria` int NOT NULL,
  `nomcategoria` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`idCategoria`, `nomcategoria`) VALUES
(1, 'Gerente'),
(2, 'Jefe de cocina'),
(3, 'Mesero'),
(4, 'Cajero'),
(5, 'Asistente de Cocina');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `idcliente` int NOT NULL,
  `fk_dni` varchar(8) NOT NULL,
  `fk_idestados` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`idcliente`, `fk_dni`, `fk_idestados`) VALUES
(1, '70000003', 1),
(2, '70000004', 2),
(3, '70000007', 2),
(4, '95623551', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comprobantes`
--

CREATE TABLE `comprobantes` (
  `codComprobante` varchar(8) NOT NULL,
  `impuesto` decimal(7,2) NOT NULL,
  `fk_reserva` int NOT NULL,
  `fk_tipocomprobante` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `comprobantes`
--

INSERT INTO `comprobantes` (`codComprobante`, `impuesto`, `fk_reserva`, `fk_tipocomprobante`) VALUES
('BO-00001', '0.18', 1, 1),
('BO-00002', '0.18', 2, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles`
--

CREATE TABLE `detalles` (
  `idDetalle` int NOT NULL,
  `cantidad` int NOT NULL,
  `fk_idReserva` int NOT NULL,
  `fk_idPlato` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `detalles`
--

INSERT INTO `detalles` (`idDetalle`, `cantidad`, `fk_idReserva`, `fk_idPlato`) VALUES
(1, 3, 1, 1),
(2, 1, 1, 2),
(5, 3, 5, 2),
(6, 2, 5, 5),
(7, 5, 5, 9),
(8, 1, 5, 10),
(10, 2, 5, 6),
(11, 2, 5, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
--

CREATE TABLE `empleados` (
  `idEmpleado` int NOT NULL,
  `login` varchar(45) NOT NULL,
  `clave` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `foto` text CHARACTER SET utf8 COLLATE utf8_general_ci,
  `fk_idCategoria` int NOT NULL,
  `fk_idestados` int NOT NULL,
  `fk_dni` varchar(8) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 KEY_BLOCK_SIZE=8;

--
-- Volcado de datos para la tabla `empleados`
--

INSERT INTO `empleados` (`idEmpleado`, `login`, `clave`, `foto`, `fk_idCategoria`, `fk_idestados`, `fk_dni`) VALUES
(1, 'mesero1', '202cb962ac59075b964b07152d234b70', '', 3, 2, '70000001'),
(2, 'raper', '202cb962ac59075b964b07152d234b70', 'leo1.png', 4, 2, '70000002'),
(3, 'tavio123', '202cb962ac59075b964b07152d234b70', 'chefTavio_2.png', 2, 1, '74355516'),
(4, 'fran', '$2a$10$UH6O/icQra3d0/vg4NTHM.RMwsadpJqEnXBdIyCMBbbFht7BTdmMu', 'xin.png', 1, 1, '75451742'),
(5, 'leo', '$2a$10$SWwGjCSbGSbQrA1rsOj8A.M2S69WGDRwD4JPaFKB1tEFFbzam4T/.', '', 1, 2, '75486235'),
(6, 'pablito', '$2a$10$XLUeHMcFDVkfRuCDnIq30eq5P80fwE2Ou53RsZc4o8wCzDIeaSmLq', '', 1, 2, '62535148'),
(7, '123', '742996de6205cc365427554b04a5c2e3', 'CapturaSAL.PNG', 3, 2, '45963562'),
(8, 'bernal', 'd2631463d3db272e4a5a1f1543646233', 'chefDimon_2.png', 2, 1, '45963592'),
(9, 'leonard', 'd8bca66511c69db277260cf24c3281e4', 'leo1.png', 2, 2, '75844226'),
(10, 'leoleo', '992983621f2862da72d988698772c7cd', 'leo1.png', 2, 2, '62351426'),
(11, 'leito', '$2a$10$.G9VP5pbAwW9NeDHB6V5b.H8JGe9OYU4FFVgn/DUwUp7vZJKKNHUW', 'leo1.png', 2, 1, '75451263');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `especialidades`
--

CREATE TABLE `especialidades` (
  `idEspecialidad` int NOT NULL,
  `nomespecialidad` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `especialidades`
--

INSERT INTO `especialidades` (`idEspecialidad`, `nomespecialidad`) VALUES
(1, 'Cocina Regional'),
(2, 'Cocina Internacional'),
(3, 'Cocina Peruana'),
(4, 'Cocina Italiana');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estados`
--

CREATE TABLE `estados` (
  `idestados` int NOT NULL,
  `nomestado` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `estados`
--

INSERT INTO `estados` (`idestados`, `nomestado`) VALUES
(1, 'Activo'),
(2, 'Inactivo'),
(3, 'Pagado'),
(4, 'Pendiente');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mesas`
--

CREATE TABLE `mesas` (
  `idmesa` int NOT NULL,
  `numero` varchar(45) NOT NULL,
  `aforo` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `mesas`
--

INSERT INTO `mesas` (`idmesa`, `numero`, `aforo`) VALUES
(1, '1', 6),
(2, '2', 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos`
--

CREATE TABLE `pagos` (
  `idPago` int NOT NULL,
  `total_pago` decimal(7,2) NOT NULL,
  `fecha_emision` varchar(45) NOT NULL,
  `fk_idReserva` int NOT NULL,
  `fk_tipopago` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `pagos`
--

INSERT INTO `pagos` (`idPago`, `total_pago`, `fecha_emision`, `fk_idReserva`, `fk_tipopago`) VALUES
(1, '119.06', '2021-09-22', 1, 1),
(2, '295.35', '2021-09-22', 2, 2),
(3, '85.20', '2021-10-15', 2, 1),
(4, '217.40', '2021-10-15', 5, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personas`
--

CREATE TABLE `personas` (
  `dni` varchar(8) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `apellido` varchar(45) NOT NULL,
  `direccion` varchar(45) NOT NULL,
  `telefono` varchar(9) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `personas`
--

INSERT INTO `personas` (`dni`, `nombre`, `apellido`, `direccion`, `telefono`) VALUES
('45963562', 'TT', 'ttt', 'tt', '963366251'),
('45963592', 'Bernal', 'Bautista Carrion', 'Huaraz', '965136224'),
('62351426', 'Leonard', 'Caceres Albinagorta', 'Recuay', '965136227'),
('62535148', 'Pablo', 'Montes Mejia', 'Yungay', '956321553'),
('70000001', 'Carlos', 'Rojas Díaz', 'Av. Rosales 123', '900000001'),
('70000002', 'Rapero', 'Carrión', 'Av. Las Rosas', '900000002'),
('70000003', 'Roxana', 'Araujo', 'Av. Los Rosales', '900000003'),
('70000004', 'Marta', 'Arias', 'Psje. Puente Camote', '900000004'),
('70000005', 'Pedro', 'Soto', 'Jr. La Unión', '900000005'),
('70000006', 'Roberto', 'Lara', 'Av. Independencia', '900000006'),
('70000007', 'Jose Emilion', 'Quispe Torres', 'Jr caraz n 465', '987321654'),
('74355516', 'Tavio Jose', 'Ccama Melgarejo', 'Psj Llanganuco n 428', '960490987'),
('75451263', 'Leonard', 'Caceres Albinagorta', 'Recuay', '965136227'),
('75451742', 'Fran', 'Torres Penadillo', 'Huaraz', '983611729'),
('75486235', 'Leonard', 'Caceres', 'Recuay Nº5', '965336216'),
('75844226', 'Leonard', 'Caceres Albinagorta', 'Recuay', '965136227'),
('95623551', 'Eberth', 'Alvarado Leon', 'Vichay alto', '956124831');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `platos`
--

CREATE TABLE `platos` (
  `idPlato` int NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `precio` decimal(7,2) NOT NULL,
  `foto` text,
  `fk_idEspecialidad` int NOT NULL,
  `fk_tipoPlato` int NOT NULL,
  `fk_idestados` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `platos`
--

INSERT INTO `platos` (`idPlato`, `descripcion`, `precio`, `foto`, `fk_idEspecialidad`, `fk_tipoPlato`, `fk_idestados`) VALUES
(1, 'Ají de Gallina', '25.40', NULL, 3, 1, 1),
(2, 'Llunca con Gallina', '20.60', NULL, 1, 1, 1),
(3, '1/4 de Pollo a la brasa', '20.80', NULL, 3, 2, 2),
(4, '1 Pizza clásica', '22.80', NULL, 4, 2, 2),
(5, 'Rocoto Relleno', '30.00', NULL, 1, 4, 1),
(6, 'Sopa Criolla', '5.60', NULL, 3, 2, 1),
(7, 'Ceviche', '12.30', NULL, 2, 2, 2),
(8, 'Sopa Seca', '5.00', '2.jpg', 3, 2, 1),
(9, 'test', '5.60', 'ag.png', 1, 1, 1),
(10, 'test1', '5.60', 'default.png', 1, 1, 1),
(11, 'test3', '22.00', 'chefDimon_2.png', 3, 3, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reservas`
--

CREATE TABLE `reservas` (
  `idReserva` int NOT NULL,
  `monto` decimal(7,2) NOT NULL,
  `nComensales` int NOT NULL,
  `fk_idEmpleado` int NOT NULL,
  `fk_codCliente` int NOT NULL,
  `fk_idturno` int NOT NULL,
  `fk_idestados` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `reservas`
--

INSERT INTO `reservas` (`idReserva`, `monto`, `nComensales`, `fk_idEmpleado`, `fk_codCliente`, `fk_idturno`, `fk_idestados`) VALUES
(1, '100.90', 3, 1, 1, 2, 1),
(2, '85.20', 4, 1, 2, 3, 3),
(3, '0.00', 4, 4, 1, 1, 1),
(4, '0.00', 4, 4, 1, 1, 1),
(5, '217.40', 4, 4, 1, 1, 3),
(6, '0.00', 4, 4, 1, 3, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rservaxmesa`
--

CREATE TABLE `rservaxmesa` (
  `fk_idReserva` int NOT NULL,
  `fk_idmesa` int NOT NULL,
  `fecha` date NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_fin` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `rservaxmesa`
--

INSERT INTO `rservaxmesa` (`fk_idReserva`, `fk_idmesa`, `fecha`, `hora_inicio`, `hora_fin`) VALUES
(1, 1, '2021-09-22', '14:30:30', '15:40:30'),
(2, 2, '2021-09-22', '20:30:29', '21:40:29'),
(5, 1, '2021-10-16', '12:51:07', '17:51:07'),
(6, 1, '2021-10-15', '16:06:25', '18:33:25');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sessions`
--

CREATE TABLE `sessions` (
  `session_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `expires` int UNSIGNED NOT NULL,
  `data` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `sessions`
--

INSERT INTO `sessions` (`session_id`, `expires`, `data`) VALUES
('1xR0BxvSg0QU74FDqunHPQw2GHUqYPyK', 1634361481, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('3e7HMfGG-4EHQq-8kdZw7ohLq0vJm6KD', 1634372752, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{},\"passport\":{\"user\":{\"idEmpleado\":4,\"login\":\"fran\",\"clave\":\"$2a$10$UH6O/icQra3d0/vg4NTHM.RMwsadpJqEnXBdIyCMBbbFht7BTdmMu\",\"fk_idCategoria\":1,\"fk_idestados\":1,\"fk_dni\":\"75451742\"}}}'),
('6-c7eMCObl8JbwQjJwOdP3WKTSRRk463', 1634369809, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('GjRklTGcq6FG6Vw2a0uieJmcP0AfEcBo', 1634367914, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('Nsjy2CEoS07zxxH6jC_mcO_7GPiTnSoR', 1634367914, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('RbtP2AoN-w3htiCGeSa2JBnlx-2nxQl7', 1634350269, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('dlNPwyRySrjGeSWnYCinFUHdeD_zEK95', 1634399498, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{},\"passport\":{\"user\":{\"idEmpleado\":11,\"login\":\"leito\",\"clave\":\"$2a$10$.G9VP5pbAwW9NeDHB6V5b.H8JGe9OYU4FFVgn/DUwUp7vZJKKNHUW\",\"foto\":\"leo1.png\",\"fk_idCategoria\":2,\"fk_idestados\":1,\"fk_dni\":\"75451263\"}}}'),
('fpXXT5CmqpiW9CwbZsOV5Nec4di0hoUK', 1634361481, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('vq5tqHWC1ufjGvSDaoSXJLnGvOgeHxP3', 1634432018, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{},\"passport\":{\"user\":{\"idEmpleado\":4,\"login\":\"fran\",\"clave\":\"$2a$10$UH6O/icQra3d0/vg4NTHM.RMwsadpJqEnXBdIyCMBbbFht7BTdmMu\",\"foto\":\"xin.png\",\"fk_idCategoria\":1,\"fk_idestados\":1,\"fk_dni\":\"75451742\"}}}'),
('xe0OuCKhOgq1B5aJP5oWglb9TTKzKs5N', 1634367914, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_compobate`
--

CREATE TABLE `tipo_compobate` (
  `idtipo_compobante` int NOT NULL,
  `nomTipoCompro` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipo_compobate`
--

INSERT INTO `tipo_compobate` (`idtipo_compobante`, `nomTipoCompro`) VALUES
(1, 'Boleta'),
(2, 'Factura');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_pago`
--

CREATE TABLE `tipo_pago` (
  `idtipopago` int NOT NULL,
  `nomTipoPago` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipo_pago`
--

INSERT INTO `tipo_pago` (`idtipopago`, `nomTipoPago`) VALUES
(1, 'Efectivo'),
(2, 'Tarjeta');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_platos`
--

CREATE TABLE `tipo_platos` (
  `idtipoPlato` int NOT NULL,
  `nom_tipoplato` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipo_platos`
--

INSERT INTO `tipo_platos` (`idtipoPlato`, `nom_tipoplato`) VALUES
(1, 'Plato de Fondo'),
(2, 'Sopas'),
(3, 'Cena'),
(4, 'Plato de Postre');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `turnos`
--

CREATE TABLE `turnos` (
  `idturno` int NOT NULL,
  `nombreturno` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `turnos`
--

INSERT INTO `turnos` (`idturno`, `nombreturno`) VALUES
(1, 'Mañana'),
(2, 'Tarde'),
(3, 'Noche');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_cliente`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_cliente` (
`apellido` varchar(45)
,`direccion` varchar(45)
,`dni` varchar(8)
,`fk_dni` varchar(8)
,`fk_idestados` int
,`idcliente` int
,`idestados` int
,`nombre` varchar(45)
,`nomestado` varchar(45)
,`telefono` varchar(9)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_clientes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_clientes` (
`CLIENTE` varchar(91)
,`DIRECCION` varchar(45)
,`DNI` varchar(8)
,`ID` int
,`TELEFONO` varchar(9)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_empleado`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_empleado` (
`apellido` varchar(45)
,`clave` varchar(500)
,`direccion` varchar(45)
,`dni` varchar(8)
,`fk_dni` varchar(8)
,`fk_idCategoria` int
,`fk_idestados` int
,`foto` text
,`idCategoria` int
,`idEmpleado` int
,`idestados` int
,`login` varchar(45)
,`nombre` varchar(45)
,`nomcategoria` varchar(25)
,`nomestado` varchar(45)
,`telefono` varchar(9)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_empleados`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_empleados` (
`CATEGORIA` varchar(25)
,`DIRECCION` varchar(45)
,`DNI` varchar(8)
,`EMPLEADO` varchar(91)
,`ID` int
,`TELEFONO` varchar(9)
,`USUARIO` varchar(45)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_platos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_platos` (
`ESPECIALIDAD` varchar(45)
,`foto` text
,`ID` int
,`idEspecialidad` int
,`idtipoPlato` int
,`PLATO` varchar(255)
,`PRECIO` decimal(7,2)
,`TIPO` varchar(45)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_reservas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_reservas` (
`CLIENTE` varchar(91)
,`codComprobante` varchar(8)
,`EMPLEADO` varchar(91)
,`fecha` date
,`fk_codCliente` int
,`fk_idEmpleado` int
,`fk_idestados` int
,`fk_idturno` int
,`hora_fin` time
,`hora_inicio` time
,`idReserva` int
,`idtipo_compobante` int
,`impuesto` decimal(7,2)
,`mesa` int
,`nComensales` int
,`nombreturno` varchar(45)
,`nomestado` varchar(45)
,`nomTipoCompro` varchar(45)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_reservas_ahora`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_reservas_ahora` (
`CLIENTE` varchar(91)
,`EMPLEADO` varchar(91)
,`fecha` date
,`hora_fin` time
,`hora_inicio` time
,`idReserva` int
,`mesa` int
,`nComensales` int
,`nombreturno` varchar(45)
,`nomestado` varchar(45)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_reservas_hoy`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_reservas_hoy` (
`CLIENTE` varchar(91)
,`EMPLEADO` varchar(91)
,`fecha` date
,`hora_fin` time
,`hora_inicio` time
,`idReserva` int
,`mesa` int
,`nComensales` int
,`nombreturno` varchar(45)
,`nomestado` varchar(45)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_reservav`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_reservav` (
`CLIENTE` varchar(91)
,`EMPLEADO` varchar(91)
,`fecha` date
,`fk_codCliente` int
,`fk_idEmpleado` int
,`fk_idestados` int
,`fk_idturno` int
,`hora_fin` time
,`hora_inicio` time
,`idReserva` int
,`mesa` int
,`nComensales` int
,`nombreturno` varchar(45)
,`nomestado` varchar(45)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `v_cliente`
--
DROP TABLE IF EXISTS `v_cliente`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_cliente`  AS  select `p`.`dni` AS `dni`,`p`.`nombre` AS `nombre`,`p`.`apellido` AS `apellido`,`p`.`direccion` AS `direccion`,`p`.`telefono` AS `telefono`,`c`.`idcliente` AS `idcliente`,`c`.`fk_dni` AS `fk_dni`,`c`.`fk_idestados` AS `fk_idestados`,`e`.`idestados` AS `idestados`,`e`.`nomestado` AS `nomestado` from ((`personas` `p` join `clientes` `c` on((`p`.`dni` = `c`.`fk_dni`))) join `estados` `e` on((`e`.`idestados` = `c`.`fk_idestados`))) where (`e`.`idestados` = 1) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_clientes`
--
DROP TABLE IF EXISTS `v_clientes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_clientes`  AS  select `c`.`idcliente` AS `ID`,`p`.`dni` AS `DNI`,concat_ws(' ',`p`.`nombre`,`p`.`apellido`) AS `CLIENTE`,`p`.`direccion` AS `DIRECCION`,`p`.`telefono` AS `TELEFONO` from (`clientes` `c` join `personas` `p` on((`c`.`fk_dni` = `p`.`dni`))) where (`c`.`fk_idestados` = 1) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_empleado`
--
DROP TABLE IF EXISTS `v_empleado`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_empleado`  AS  select `p`.`dni` AS `dni`,`p`.`nombre` AS `nombre`,`p`.`apellido` AS `apellido`,`p`.`direccion` AS `direccion`,`p`.`telefono` AS `telefono`,`e`.`idEmpleado` AS `idEmpleado`,`e`.`login` AS `login`,`e`.`clave` AS `clave`,`e`.`foto` AS `foto`,`e`.`fk_idCategoria` AS `fk_idCategoria`,`e`.`fk_idestados` AS `fk_idestados`,`e`.`fk_dni` AS `fk_dni`,`c`.`idCategoria` AS `idCategoria`,`c`.`nomcategoria` AS `nomcategoria`,`s`.`idestados` AS `idestados`,`s`.`nomestado` AS `nomestado` from (((`personas` `p` join `empleados` `e` on((`p`.`dni` = `e`.`fk_dni`))) join `categorias` `c` on((`e`.`fk_idCategoria` = `c`.`idCategoria`))) join `estados` `s` on((`s`.`idestados` = `e`.`fk_idestados`))) where (`s`.`idestados` = 1) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_empleados`
--
DROP TABLE IF EXISTS `v_empleados`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_empleados`  AS  select `e`.`idEmpleado` AS `ID`,`p`.`dni` AS `DNI`,concat_ws(' ',`p`.`nombre`,`p`.`apellido`) AS `EMPLEADO`,`p`.`direccion` AS `DIRECCION`,`p`.`telefono` AS `TELEFONO`,`e`.`login` AS `USUARIO`,`c`.`nomcategoria` AS `CATEGORIA` from ((`empleados` `e` join `personas` `p` on((`e`.`fk_dni` = `p`.`dni`))) join `categorias` `c` on((`c`.`idCategoria` = `e`.`fk_idCategoria`))) where (`e`.`fk_idestados` = 1) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_platos`
--
DROP TABLE IF EXISTS `v_platos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_platos`  AS  select `p`.`idPlato` AS `ID`,`p`.`descripcion` AS `PLATO`,`p`.`precio` AS `PRECIO`,`p`.`foto` AS `foto`,`tp`.`nom_tipoplato` AS `TIPO`,`e`.`nomespecialidad` AS `ESPECIALIDAD`,`e`.`idEspecialidad` AS `idEspecialidad`,`tp`.`idtipoPlato` AS `idtipoPlato` from ((`platos` `p` join `tipo_platos` `tp` on((`tp`.`idtipoPlato` = `p`.`fk_tipoPlato`))) join `especialidades` `e` on((`e`.`idEspecialidad` = `p`.`fk_idEspecialidad`))) where (`p`.`fk_idestados` = 1) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_reservas`
--
DROP TABLE IF EXISTS `v_reservas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_reservas`  AS  select `r`.`idReserva` AS `idReserva`,`r`.`fk_idEmpleado` AS `fk_idEmpleado`,concat_ws(' ',`pe`.`nombre`,`pe`.`apellido`) AS `EMPLEADO`,`r`.`fk_codCliente` AS `fk_codCliente`,concat_ws(' ',`pc`.`nombre`,`pc`.`apellido`) AS `CLIENTE`,`r`.`fk_idturno` AS `fk_idturno`,`t`.`nombreturno` AS `nombreturno`,`rm`.`fecha` AS `fecha`,`rm`.`hora_inicio` AS `hora_inicio`,`rm`.`hora_fin` AS `hora_fin`,`rm`.`fk_idmesa` AS `mesa`,`r`.`nComensales` AS `nComensales`,`com`.`codComprobante` AS `codComprobante`,`com`.`impuesto` AS `impuesto`,`tc`.`idtipo_compobante` AS `idtipo_compobante`,`tc`.`nomTipoCompro` AS `nomTipoCompro`,`r`.`fk_idestados` AS `fk_idestados`,`es`.`nomestado` AS `nomestado` from (((((((((`reservas` `r` join `rservaxmesa` `rm` on((`rm`.`fk_idReserva` = `r`.`idReserva`))) join `empleados` `e` on((`e`.`idEmpleado` = `r`.`fk_idEmpleado`))) join `clientes` `c` on((`c`.`idcliente` = `r`.`fk_codCliente`))) join `personas` `pe` on((`pe`.`dni` = `e`.`fk_dni`))) join `personas` `pc` on((`pc`.`dni` = `c`.`fk_dni`))) join `turnos` `t` on((`t`.`idturno` = `r`.`fk_idturno`))) join `comprobantes` `com` on((`com`.`fk_reserva` = `r`.`idReserva`))) join `tipo_compobate` `tc` on((`tc`.`idtipo_compobante` = `com`.`fk_tipocomprobante`))) join `estados` `es` on((`es`.`idestados` = `r`.`fk_idestados`))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_reservas_ahora`
--
DROP TABLE IF EXISTS `v_reservas_ahora`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_reservas_ahora`  AS  select `r`.`idReserva` AS `idReserva`,concat_ws(' ',`pe`.`nombre`,`pe`.`apellido`) AS `EMPLEADO`,concat_ws(' ',`pc`.`nombre`,`pc`.`apellido`) AS `CLIENTE`,`t`.`nombreturno` AS `nombreturno`,`rm`.`fecha` AS `fecha`,`rm`.`hora_inicio` AS `hora_inicio`,`rm`.`hora_fin` AS `hora_fin`,`rm`.`fk_idmesa` AS `mesa`,`r`.`nComensales` AS `nComensales`,`es`.`nomestado` AS `nomestado` from (((((((`reservas` `r` join `rservaxmesa` `rm` on((`rm`.`fk_idReserva` = `r`.`idReserva`))) join `empleados` `e` on((`e`.`idEmpleado` = `r`.`fk_idEmpleado`))) join `clientes` `c` on((`c`.`idcliente` = `r`.`fk_codCliente`))) join `personas` `pe` on((`pe`.`dni` = `e`.`fk_dni`))) join `personas` `pc` on((`pc`.`dni` = `c`.`fk_dni`))) join `turnos` `t` on((`t`.`idturno` = `r`.`fk_idturno`))) join `estados` `es` on((`es`.`idestados` = `r`.`fk_idestados`))) where ((`rm`.`hora_inicio` < curtime()) and (`rm`.`hora_fin` > curtime()) and (`rm`.`fecha` = curdate())) order by `r`.`idReserva` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_reservas_hoy`
--
DROP TABLE IF EXISTS `v_reservas_hoy`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_reservas_hoy`  AS  select `r`.`idReserva` AS `idReserva`,concat_ws(' ',`pe`.`nombre`,`pe`.`apellido`) AS `EMPLEADO`,concat_ws(' ',`pc`.`nombre`,`pc`.`apellido`) AS `CLIENTE`,`t`.`nombreturno` AS `nombreturno`,`rm`.`fecha` AS `fecha`,`rm`.`hora_inicio` AS `hora_inicio`,`rm`.`hora_fin` AS `hora_fin`,`rm`.`fk_idmesa` AS `mesa`,`r`.`nComensales` AS `nComensales`,`es`.`nomestado` AS `nomestado` from (((((((`reservas` `r` join `rservaxmesa` `rm` on((`rm`.`fk_idReserva` = `r`.`idReserva`))) join `empleados` `e` on((`e`.`idEmpleado` = `r`.`fk_idEmpleado`))) join `clientes` `c` on((`c`.`idcliente` = `r`.`fk_codCliente`))) join `personas` `pe` on((`pe`.`dni` = `e`.`fk_dni`))) join `personas` `pc` on((`pc`.`dni` = `c`.`fk_dni`))) join `turnos` `t` on((`t`.`idturno` = `r`.`fk_idturno`))) join `estados` `es` on((`es`.`idestados` = `r`.`fk_idestados`))) where (`rm`.`fecha` = curdate()) order by `r`.`idReserva` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_reservav`
--
DROP TABLE IF EXISTS `v_reservav`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_reservav`  AS  select `r`.`idReserva` AS `idReserva`,`r`.`fk_idEmpleado` AS `fk_idEmpleado`,concat_ws(' ',`pe`.`nombre`,`pe`.`apellido`) AS `EMPLEADO`,`r`.`fk_codCliente` AS `fk_codCliente`,concat_ws(' ',`pc`.`nombre`,`pc`.`apellido`) AS `CLIENTE`,`r`.`fk_idturno` AS `fk_idturno`,`t`.`nombreturno` AS `nombreturno`,`rm`.`fecha` AS `fecha`,`rm`.`hora_inicio` AS `hora_inicio`,`rm`.`hora_fin` AS `hora_fin`,`rm`.`fk_idmesa` AS `mesa`,`r`.`nComensales` AS `nComensales`,`r`.`fk_idestados` AS `fk_idestados`,`es`.`nomestado` AS `nomestado` from (((((((`reservas` `r` join `rservaxmesa` `rm` on((`rm`.`fk_idReserva` = `r`.`idReserva`))) join `empleados` `e` on((`e`.`idEmpleado` = `r`.`fk_idEmpleado`))) join `clientes` `c` on((`c`.`idcliente` = `r`.`fk_codCliente`))) join `personas` `pe` on((`pe`.`dni` = `e`.`fk_dni`))) join `personas` `pc` on((`pc`.`dni` = `c`.`fk_dni`))) join `turnos` `t` on((`t`.`idturno` = `r`.`fk_idturno`))) join `estados` `es` on((`es`.`idestados` = `r`.`fk_idestados`))) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`idCategoria`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`idcliente`),
  ADD KEY `fk_cliente_persona1_idx` (`fk_dni`),
  ADD KEY `fk_cliente_estados1_idx` (`fk_idestados`);

--
-- Indices de la tabla `comprobantes`
--
ALTER TABLE `comprobantes`
  ADD PRIMARY KEY (`codComprobante`),
  ADD KEY `fk_comprobante_reserva1_idx` (`fk_reserva`),
  ADD KEY `fk_comprobante_tipo_compobate1_idx` (`fk_tipocomprobante`);

--
-- Indices de la tabla `detalles`
--
ALTER TABLE `detalles`
  ADD PRIMARY KEY (`idDetalle`),
  ADD KEY `fk_Reserva_has_Plato_Plato1_idx` (`fk_idPlato`),
  ADD KEY `fk_Reserva_has_Plato_Reserva1_idx` (`fk_idReserva`);

--
-- Indices de la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD PRIMARY KEY (`idEmpleado`),
  ADD KEY `fk_Empleado_Persona_idx` (`idEmpleado`),
  ADD KEY `fk_Empleado_Categoria1_idx` (`fk_idCategoria`),
  ADD KEY `fk_empleado_estados1_idx` (`fk_idestados`),
  ADD KEY `fk_empleado_persona1_idx` (`fk_dni`);

--
-- Indices de la tabla `especialidades`
--
ALTER TABLE `especialidades`
  ADD PRIMARY KEY (`idEspecialidad`);

--
-- Indices de la tabla `estados`
--
ALTER TABLE `estados`
  ADD PRIMARY KEY (`idestados`);

--
-- Indices de la tabla `mesas`
--
ALTER TABLE `mesas`
  ADD PRIMARY KEY (`idmesa`);

--
-- Indices de la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD PRIMARY KEY (`idPago`),
  ADD KEY `fk_Pago_Reserva1_idx` (`fk_idReserva`),
  ADD KEY `fk_pago_tipo_pago1_idx` (`fk_tipopago`);

--
-- Indices de la tabla `personas`
--
ALTER TABLE `personas`
  ADD PRIMARY KEY (`dni`);

--
-- Indices de la tabla `platos`
--
ALTER TABLE `platos`
  ADD PRIMARY KEY (`idPlato`),
  ADD UNIQUE KEY `idPlato_UNIQUE` (`idPlato`),
  ADD KEY `fk_plato_especialidad1_idx` (`fk_idEspecialidad`),
  ADD KEY `fk_plato_tipo_plato1_idx` (`fk_tipoPlato`),
  ADD KEY `fk_plato_estados1_idx` (`fk_idestados`);

--
-- Indices de la tabla `reservas`
--
ALTER TABLE `reservas`
  ADD PRIMARY KEY (`idReserva`),
  ADD KEY `fk_Reserva_Empleado1_idx` (`fk_idEmpleado`),
  ADD KEY `fk_reserva_cliente1_idx` (`fk_codCliente`),
  ADD KEY `fk_reserva_turno1_idx` (`fk_idturno`),
  ADD KEY `fk_reserva_estados1_idx` (`fk_idestados`);

--
-- Indices de la tabla `rservaxmesa`
--
ALTER TABLE `rservaxmesa`
  ADD PRIMARY KEY (`fk_idReserva`,`fk_idmesa`),
  ADD KEY `fk_reserva_has_mesa_mesa1_idx` (`fk_idmesa`),
  ADD KEY `fk_reserva_has_mesa_reserva1_idx` (`fk_idReserva`);

--
-- Indices de la tabla `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`session_id`);

--
-- Indices de la tabla `tipo_compobate`
--
ALTER TABLE `tipo_compobate`
  ADD PRIMARY KEY (`idtipo_compobante`);

--
-- Indices de la tabla `tipo_pago`
--
ALTER TABLE `tipo_pago`
  ADD PRIMARY KEY (`idtipopago`);

--
-- Indices de la tabla `tipo_platos`
--
ALTER TABLE `tipo_platos`
  ADD PRIMARY KEY (`idtipoPlato`);

--
-- Indices de la tabla `turnos`
--
ALTER TABLE `turnos`
  ADD PRIMARY KEY (`idturno`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `idCategoria` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `idcliente` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `detalles`
--
ALTER TABLE `detalles`
  MODIFY `idDetalle` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `empleados`
--
ALTER TABLE `empleados`
  MODIFY `idEmpleado` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `especialidades`
--
ALTER TABLE `especialidades`
  MODIFY `idEspecialidad` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `estados`
--
ALTER TABLE `estados`
  MODIFY `idestados` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `mesas`
--
ALTER TABLE `mesas`
  MODIFY `idmesa` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `pagos`
--
ALTER TABLE `pagos`
  MODIFY `idPago` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `platos`
--
ALTER TABLE `platos`
  MODIFY `idPlato` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `reservas`
--
ALTER TABLE `reservas`
  MODIFY `idReserva` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `tipo_compobate`
--
ALTER TABLE `tipo_compobate`
  MODIFY `idtipo_compobante` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `tipo_pago`
--
ALTER TABLE `tipo_pago`
  MODIFY `idtipopago` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `tipo_platos`
--
ALTER TABLE `tipo_platos`
  MODIFY `idtipoPlato` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `turnos`
--
ALTER TABLE `turnos`
  MODIFY `idturno` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD CONSTRAINT `fk_cliente_estados1` FOREIGN KEY (`fk_idestados`) REFERENCES `estados` (`idestados`),
  ADD CONSTRAINT `fk_cliente_persona1` FOREIGN KEY (`fk_dni`) REFERENCES `personas` (`dni`);

--
-- Filtros para la tabla `comprobantes`
--
ALTER TABLE `comprobantes`
  ADD CONSTRAINT `fk_comprobante_reserva1` FOREIGN KEY (`fk_reserva`) REFERENCES `reservas` (`idReserva`),
  ADD CONSTRAINT `fk_comprobante_tipo_compobate1` FOREIGN KEY (`fk_tipocomprobante`) REFERENCES `tipo_compobate` (`idtipo_compobante`);

--
-- Filtros para la tabla `detalles`
--
ALTER TABLE `detalles`
  ADD CONSTRAINT `fk_Reserva_has_Plato_Plato1` FOREIGN KEY (`fk_idPlato`) REFERENCES `platos` (`idPlato`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_Reserva_has_Plato_Reserva1` FOREIGN KEY (`fk_idReserva`) REFERENCES `reservas` (`idReserva`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD CONSTRAINT `fk_Empleado_Categoria1` FOREIGN KEY (`fk_idCategoria`) REFERENCES `categorias` (`idCategoria`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_empleado_estados1` FOREIGN KEY (`fk_idestados`) REFERENCES `estados` (`idestados`),
  ADD CONSTRAINT `fk_empleado_persona1` FOREIGN KEY (`fk_dni`) REFERENCES `personas` (`dni`);

--
-- Filtros para la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD CONSTRAINT `fk_Pago_Reserva1` FOREIGN KEY (`fk_idReserva`) REFERENCES `reservas` (`idReserva`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pago_tipo_pago1` FOREIGN KEY (`fk_tipopago`) REFERENCES `tipo_pago` (`idtipopago`);

--
-- Filtros para la tabla `platos`
--
ALTER TABLE `platos`
  ADD CONSTRAINT `fk_plato_especialidad1` FOREIGN KEY (`fk_idEspecialidad`) REFERENCES `especialidades` (`idEspecialidad`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_plato_estados1` FOREIGN KEY (`fk_idestados`) REFERENCES `estados` (`idestados`),
  ADD CONSTRAINT `fk_plato_tipo_plato1` FOREIGN KEY (`fk_tipoPlato`) REFERENCES `tipo_platos` (`idtipoPlato`);

--
-- Filtros para la tabla `reservas`
--
ALTER TABLE `reservas`
  ADD CONSTRAINT `fk_reserva_cliente1` FOREIGN KEY (`fk_codCliente`) REFERENCES `clientes` (`idcliente`),
  ADD CONSTRAINT `fk_Reserva_Empleado1` FOREIGN KEY (`fk_idEmpleado`) REFERENCES `empleados` (`idEmpleado`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_reserva_estados1` FOREIGN KEY (`fk_idestados`) REFERENCES `estados` (`idestados`),
  ADD CONSTRAINT `fk_reserva_turno1` FOREIGN KEY (`fk_idturno`) REFERENCES `turnos` (`idturno`);

--
-- Filtros para la tabla `rservaxmesa`
--
ALTER TABLE `rservaxmesa`
  ADD CONSTRAINT `fk_reserva_has_mesa_mesa1` FOREIGN KEY (`fk_idmesa`) REFERENCES `mesas` (`idmesa`),
  ADD CONSTRAINT `fk_reserva_has_mesa_reserva1` FOREIGN KEY (`fk_idReserva`) REFERENCES `reservas` (`idReserva`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
