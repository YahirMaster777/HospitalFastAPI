CREATE DATABASE  IF NOT EXISTS `hospital_general_9a_idgs2_210540` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `hospital_general_9a_idgs2_210540`;
-- MySQL dump 10.13  Distrib 8.0.36, for Win64 (x86_64)
--
-- Host: localhost    Database: hospital_general_9a_idgs2_210540
-- ------------------------------------------------------
-- Server version	8.0.36

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `tbb_aprobaciones`
--

DROP TABLE IF EXISTS `tbb_aprobaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_aprobaciones` (
  `ID` int NOT NULL,
  `Personal_Medico_ID` int NOT NULL,
  `Solicitud_id` int NOT NULL,
  `Comentario` text,
  `Estatus` enum('En Proceso','Pausado','Aprobado','Reprogramado','Cancelado') NOT NULL,
  `Tipo` enum('Servicio Interno','Traslados','Subrogado','Administrativo') NOT NULL,
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_aprobaciones`
--

LOCK TABLES `tbb_aprobaciones` WRITE;
/*!40000 ALTER TABLE `tbb_aprobaciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbb_aprobaciones` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`carlos.crespo`@`%`*/ /*!50003 TRIGGER `tbb_aprobaciones_BEFORE_INSERT` BEFORE INSERT ON `tbb_aprobaciones` FOR EACH ROW BEGIN
    -- Declaración de variables
    DECLARE v_estatus_descripcion VARCHAR(20) DEFAULT 'En Proceso';
    DECLARE v_tipo_solicitud VARCHAR(20) DEFAULT 'Servicio Interno';
    DECLARE personal_medico VARCHAR(200) DEFAULT 'No Aplica';
    DECLARE v_personal_medico_id INT;
    DECLARE v_solicitud_id INT;
    DECLARE solicitud VARCHAR(200) DEFAULT 'Sin datos de Solicitud';

	-- Restringir titulo
	-- DECLARE v_titulo VARCHAR(20);
    
    -- Asignar el id del personal médico
    SET v_personal_medico_id = NEW.personal_medico_id;
    
    -- Asignación de la solicitud
    SET v_solicitud_id = NEW.solicitud_id;
    
    
    -- ----------------------------------
        -- Verificar mediante una condicion si el Titulo es permitido
    /*
    SELECT p.Titulo INTO v_titulo
    FROM tbb_personas p
    WHERE p.id = v_personal_medico_id;

    IF v_titulo NOT IN ('Dr.', 'Dra.',  'Lic.', 'Ing.', 'Tec.', 'Q.F.C.') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Titulo no permitido. La Solicitud solo está permitida para Dr., Dra., Lic., Ing, Tec., Q.F.C.';
    END IF;
    */
	-- ----------------------------------
    -- Intentar obtener el nombre del personal médico con su rol
    BEGIN
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET personal_medico = 'No Aplica - Sin Rol';
        SELECT CONCAT(p.Titulo, ' ', p.Nombre, ' ', p.Primer_Apellido, ' ', COALESCE(p.Segundo_Apellido, ''), ' - ', COALESCE(r.nombre, 'Sin Rol'))
        INTO personal_medico
        FROM tbb_personas p
        LEFT JOIN tbc_roles r ON p.id = r.id
        WHERE p.id = v_personal_medico_id AND p.Titulo IN ('Dr.', 'Dra.',  'Lic.', 'Ing.', 'Tec.', 'Q.F.C.');
    END;

    -- Intentar obtener la descripción de la solicitud
    BEGIN
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET solicitud = 'Sin datos de Solicitud';
		SELECT CONCAT('Su Prioridad es: ', Prioridad, ' - ', 'Su estatus es: ', Estatus, ' ')
		INTO solicitud
		FROM tbd_solicitudes
		WHERE id = v_solicitud_id;
	END;
    
    -- Validación del estatus del registro
    CASE NEW.Estatus
        WHEN 'En Proceso' THEN SET v_estatus_descripcion = 'En Proceso';
        WHEN 'Pausado' THEN SET v_estatus_descripcion = 'Pausado';
        WHEN 'Aprobado' THEN SET v_estatus_descripcion = 'Aprobado';
        WHEN 'Reprogramado' THEN SET v_estatus_descripcion = 'Reprogramado';
        WHEN 'Cancelado' THEN SET v_estatus_descripcion = 'Cancelado';
    END CASE;

    -- Validación del tipo de solicitud
    CASE NEW.tipo
        WHEN 'Servicio Interno' THEN SET v_tipo_solicitud = 'Servicio Interno';
        WHEN 'Traslados' THEN SET v_tipo_solicitud = 'Traslados';
        WHEN 'Subrogado' THEN SET v_tipo_solicitud = 'Subrogado';
        WHEN 'Administrativo' THEN SET v_tipo_solicitud = 'Administrativo';
    END CASE;

    -- Inserción en la tabla tbi_bitacora
    INSERT INTO tbi_bitacora (
        Usuario,
        Operacion,
        Tabla,
        Descripcion,
        Estatus,
        Fecha_Registro
    ) VALUES (
        CURRENT_USER(),
        'Create',
        'tbb_aprobaciones',
        CONCAT(
            'Se ha registrado una nueva aprobación con los siguientes datos:', '\n',
            'Personal Médico: ', personal_medico, '\n',
            'Solicitud: ', solicitud , '\n',
            'Comentario: ', COALESCE(NEW.comentario, 'Sin Comentarios'), '\n',
            'Estatus: ', v_estatus_descripcion, '\n',
            'Tipo: ', v_tipo_solicitud, '\n',
            'Fecha de Registro: ', COALESCE(NEW.fecha_registro, 'N/A'), '\n',
            'Fecha de Actualización: ', COALESCE(NEW.fecha_actualizacion, 'N/A')
        ),
        default,
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`carlos.crespo`@`%`*/ /*!50003 TRIGGER `tbb_aprobaciones_BEFORE_UPDATE` BEFORE UPDATE ON `tbb_aprobaciones` FOR EACH ROW BEGIN
	set new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`carlos.crespo`@`%`*/ /*!50003 TRIGGER `tbb_aprobaciones_AFTER_UPDATE` AFTER UPDATE ON `tbb_aprobaciones` FOR EACH ROW BEGIN

	  -- Declaración de variables
    DECLARE v_estatus_descripcion VARCHAR(20) DEFAULT 'En Proceso';
    DECLARE v_tipo_solicitud VARCHAR(20) DEFAULT 'Servicio Interno';
    DECLARE personal_medico VARCHAR(200) DEFAULT 'No Aplica';
    DECLARE v_personal_medico_id INT;
    DECLARE v_solicitud_id INT;
    DECLARE solicitud VARCHAR(200) DEFAULT 'Sin datos de Solicitud';

	-- Restringir titulo
	-- DECLARE v_titulo VARCHAR(20);
    
    -- Asignar el id del personal médico
    SET v_personal_medico_id = NEW.personal_medico_id;
    
    -- Asignación de la solicitud
    SET v_solicitud_id = NEW.solicitud_id;
    
    
    -- ----------------------------------
        -- Verificar mediante una condicion si el Titulo es permitido
    /*
    SELECT p.Titulo INTO v_titulo
    FROM tbb_personas p
    WHERE p.id = v_personal_medico_id;

    IF v_titulo NOT IN ('Dr.', 'Dra.',  'Lic.', 'Ing.', 'Tec.', 'Q.F.C.') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Titulo no permitido. La Solicitud solo está permitida para Dr., Dra., Lic., Ing, Tec., Q.F.C.';
    END IF;
    */
	-- ----------------------------------
    -- Intentar obtener el nombre del personal médico con su rol
    BEGIN
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET personal_medico = 'No Aplica - Sin Rol';
        SELECT CONCAT(p.Titulo, ' ', p.Nombre, ' ', p.Primer_Apellido, ' ', COALESCE(p.Segundo_Apellido, ''), ' - ', COALESCE(r.nombre, 'Sin Rol'))
        INTO personal_medico
        FROM tbb_personas p
        LEFT JOIN tbc_roles r ON p.id = r.id
        WHERE p.id = v_personal_medico_id AND p.Titulo IN ('Dr.', 'Dra.',  'Lic.', 'Ing.', 'Tec.', 'Q.F.C.');
    END;

    -- Intentar obtener la descripción de la solicitud
    BEGIN
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET solicitud = 'Sin datos de Solicitud';
		SELECT CONCAT('Su Prioridad es: ', Prioridad, ' - ', 'Su estatus es: ', Estatus, ' ')
		INTO solicitud
		FROM tbd_solicitudes
		WHERE id = v_solicitud_id;
	END;
    
    -- Validación del estatus del registro
    CASE NEW.Estatus
        WHEN 'En Proceso' THEN SET v_estatus_descripcion = 'En Proceso';
        WHEN 'Pausado' THEN SET v_estatus_descripcion = 'Pausado';
        WHEN 'Aprobado' THEN SET v_estatus_descripcion = 'Aprobado';
        WHEN 'Reprogramado' THEN SET v_estatus_descripcion = 'Reprogramado';
        WHEN 'Cancelado' THEN SET v_estatus_descripcion = 'Cancelado';
    END CASE;
    
	CASE OLD.Estatus
        WHEN 'En Proceso' THEN SET v_estatus_descripcion = 'En Proceso';
        WHEN 'Pausado' THEN SET v_estatus_descripcion = 'Pausado';
        WHEN 'Aprobado' THEN SET v_estatus_descripcion = 'Aprobado';
        WHEN 'Reprogramado' THEN SET v_estatus_descripcion = 'Reprogramado';
        WHEN 'Cancelado' THEN SET v_estatus_descripcion = 'Cancelado';
    END CASE;

    -- Validación del tipo de solicitud
    CASE NEW.tipo
        WHEN 'Servicio Interno' THEN SET v_tipo_solicitud = 'Servicio Interno';
        WHEN 'Traslados' THEN SET v_tipo_solicitud = 'Traslados';
        WHEN 'Subrogado' THEN SET v_tipo_solicitud = 'Subrogado';
        WHEN 'Administrativo' THEN SET v_tipo_solicitud = 'Administrativo';
    END CASE;
    
	CASE OLD.tipo
        WHEN 'Servicio Interno' THEN SET v_tipo_solicitud = 'Servicio Interno';
        WHEN 'Traslados' THEN SET v_tipo_solicitud = 'Traslados';
        WHEN 'Subrogado' THEN SET v_tipo_solicitud = 'Subrogado';
        WHEN 'Administrativo' THEN SET v_tipo_solicitud = 'Administrativo';
    END CASE;

    -- Inserción en la tabla tbi_bitacora
    INSERT INTO tbi_bitacora (
        Usuario,
        Operacion,
        Tabla,
        Descripcion,
        Estatus,
        Fecha_Registro
    ) VALUES (
        CURRENT_USER(),
        'Update',
        'tbb_aprobaciones',
        CONCAT(
            'Se ha registrado una nueva aprobación con los siguientes datos:', '\n',
            'Personal Médico: ', personal_medico, '\n',
            'Solicitud: ', solicitud , '\n',
			'Comentario: ', COALESCE(CONCAT('- Se Complementó: ', NEW.comentario), COALESCE(old.comentario, 'Sin Nuevos Comentarios')),'\n',
            'Estatus Inicial: ', v_estatus_descripcion, '\n',
			'Estatus: ', COALESCE(CONCAT('- Actualizado: ', NEW.Estatus), COALESCE(old.Estatus, 'Sin Cambio de Estado')),'\n',
            'Tipo: ', v_tipo_solicitud, '\n',
			'Tipo: ', COALESCE(CONCAT('- Se Actualizo: ', NEW.Tipo), COALESCE(old.Tipo, 'Sin Cambio')),'\n',
            'Fecha de Registro: ', COALESCE(NEW.fecha_registro, 'N/A'), '\n',
            'Fecha de Actualización: ', COALESCE(NEW.fecha_actualizacion, 'N/A')
        ),
        default,
        NOW()
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`carlos.crespo`@`%`*/ /*!50003 TRIGGER `tbb_aprobaciones_AFTER_DELETE` AFTER DELETE ON `tbb_aprobaciones` FOR EACH ROW BEGIN
    -- Declaración de variables
    DECLARE v_estatus_descripcion VARCHAR(20) DEFAULT 'En Proceso';
    DECLARE v_tipo_solicitud VARCHAR(20) DEFAULT 'Servicio Interno';
    DECLARE personal_medico VARCHAR(200) DEFAULT 'No Aplica';
    DECLARE v_personal_medico_id INT;
    DECLARE v_solicitud_id INT;
    DECLARE solicitud VARCHAR(200) DEFAULT 'Sin datos de Solicitud';

	-- Restringir titulo
	-- DECLARE v_titulo VARCHAR(20);
    
    -- Asignar el id del personal médico
    SET v_personal_medico_id = old.personal_medico_id;
    
    -- Asignación de la solicitud
    SET v_solicitud_id = old.solicitud_id;
    
    
    -- ----------------------------------
        -- Verificar mediante una condicion si el Titulo es permitido
    /*
    SELECT p.Titulo INTO v_titulo
    FROM tbb_personas p
    WHERE p.id = v_personal_medico_id;

    IF v_titulo NOT IN ('Dr.', 'Dra.',  'Lic.', 'Ing.', 'Tec.', 'Q.F.C.') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Titulo no permitido. La Solicitud solo está permitida para Dr., Dra., Lic., Ing, Tec., Q.F.C.';
    END IF;
    */
	-- ----------------------------------
    -- Intentar obtener el nombre del personal médico con su rol
    BEGIN
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET personal_medico = 'No Aplica - Sin Rol';
        SELECT CONCAT(p.Titulo, ' ', p.Nombre, ' ', p.Primer_Apellido, ' ', COALESCE(p.Segundo_Apellido, ''), ' - ', COALESCE(r.nombre, 'Sin Rol'))
        INTO personal_medico
        FROM tbb_personas p
        LEFT JOIN tbc_roles r ON p.id = r.id
        WHERE p.id = v_personal_medico_id AND p.Titulo IN ('Dr.', 'Dra.',  'Lic.', 'Ing.', 'Tec.', 'Q.F.C.');
    END;

    -- Intentar obtener la descripción de la solicitud
    BEGIN
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET solicitud = 'Sin datos de Solicitud';
		SELECT CONCAT('Su Prioridad es: ', Prioridad, ' - ', 'Su estatus es: ', Estatus, ' ')
		INTO solicitud
		FROM tbd_solicitudes
		WHERE id = v_solicitud_id;
	END;
    
    -- Validación del estatus del registro
    CASE old.Estatus
        WHEN 'En Proceso' THEN SET v_estatus_descripcion = 'En Proceso';
        WHEN 'Pausado' THEN SET v_estatus_descripcion = 'Pausado';
        WHEN 'Aprobado' THEN SET v_estatus_descripcion = 'Aprobado';
        WHEN 'Reprogramado' THEN SET v_estatus_descripcion = 'Reprogramado';
        WHEN 'Cancelado' THEN SET v_estatus_descripcion = 'Cancelado';
    END CASE;

    -- Validación del tipo de solicitud
    CASE old.tipo
        WHEN 'Servicio Interno' THEN SET v_tipo_solicitud = 'Servicio Interno';
        WHEN 'Traslados' THEN SET v_tipo_solicitud = 'Traslados';
        WHEN 'Subrogado' THEN SET v_tipo_solicitud = 'Subrogado';
        WHEN 'Administrativo' THEN SET v_tipo_solicitud = 'Administrativo';
    END CASE;

    -- Inserción en la tabla tbi_bitacora
    INSERT INTO tbi_bitacora (
        Usuario,
        Operacion,
        Tabla,
        Descripcion,
        Estatus,
        Fecha_Registro
    ) VALUES (
        CURRENT_USER(),
        'Delete',
        'tbb_aprobaciones',
        CONCAT(
            'Se ha Eliminado un Registro con los Siguientes Datos:', '\n',
            'Personal Médico: ', personal_medico, '\n',
            'Solicitud: ', solicitud , '\n',
            'Comentario: ', COALESCE(old.comentario, 'Sin Comentarios'), '\n',
            'Estatus: ', v_estatus_descripcion, '\n',
            'Tipo: ', v_tipo_solicitud, '\n',
            'Fecha de Registro: ', COALESCE(old.fecha_registro, 'N/A'), '\n',
            'Fecha de Actualización: ', COALESCE(old.fecha_actualizacion, 'N/A')
        ),
        default,
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbb_cirugias`
--

DROP TABLE IF EXISTS `tbb_cirugias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_cirugias` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Tipo` varchar(50) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` text NOT NULL,
  `Personal_Medico_ID` int unsigned NOT NULL,
  `Paciente` varchar(200) NOT NULL,
  `Nivel_Urgencia` enum('Bajo','Medio','Alto') NOT NULL,
  `Horario` datetime NOT NULL,
  `Observaciones` text NOT NULL,
  `Fecha_Registro` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Valoracion_Medica` text NOT NULL,
  `Estatus` enum('Programada','En curso','Completada','Cancelada') NOT NULL,
  `Consumible` varchar(200) NOT NULL,
  `Espacio_Medico_ID` int unsigned NOT NULL,
  `Fecha_Actualizacion` datetime NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_cirugias`
--

LOCK TABLES `tbb_cirugias` WRITE;
/*!40000 ALTER TABLE `tbb_cirugias` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbb_cirugias` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`brayan.gutierrez`@`%`*/ /*!50003 TRIGGER `tbb_cirugias_AFTER_INSERT` AFTER INSERT ON `tbb_cirugias` FOR EACH ROW BEGIN

insert into tbi_bitacora VALUES
(
DEFAULT,
current_user(),
'Create',
'tbb_cirugias',
concat_ws('', 'se ha creado una nueva cirugia con los siguientes datos:',
'ID ', NEW.id,'\n',
'TIPO:', NEW.tipo, '\n',
'NOMBRE:', NEW.nombre, '\n',
'DESCRIPCION:', NEW.descripcion, '\n',
'PERSONAL_MEDICO:', NEW.personal_medico_id, '\n',
'PACIENTE: ', NEW.paciente,'\n',
'NIVEL_URGENCIA: ', NEW.nivel_urgencia,'\n',
'HORARIO: ', NEW.horario,'\n',
'OBSERVACIONES: ', NEW.observaciones,'\n',
'FECHA_REGISTRO: ', NEW.fecha_registro,'\n',
'VALORACION_MEDICA: ', NEW.valoracion_medica, '\n',
'ESTATUS: ', NEW.estatus, '\n',
'CONSUMIBLE: ', NEW.consumible,'\n',
'ESPACIO_MEDICO', NEW.espacio_medico_id,'\n'),
default,
default
);

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`brayan.gutierrez`@`%`*/ /*!50003 TRIGGER `tbb_cirugias_BEFORE_UPDATE` BEFORE UPDATE ON `tbb_cirugias` FOR EACH ROW BEGIN
set new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`brayan.gutierrez`@`%`*/ /*!50003 TRIGGER `tbb_cirugias_AFTER_UPDATE` AFTER UPDATE ON `tbb_cirugias` FOR EACH ROW BEGIN
insert into tbi_bitacora VALUES
(
DEFAULT,
current_user(),
'Update',
'tbb_cirugias',
concat_ws('', 'se ha modificado una cirugia con los siguientes datos:',
'ID ',old.id,'-', NEW.id,'\n',
'TIPO: ',old.tipo, '-', NEW.tipo, '\n',
'NOMBRE: ',old.nombre, '-', NEW.nombre, '\n',
'DESCRIPCION: ', old.descripcion, '-', NEW.descripcion, '\n',
'PERSONAL_MEDICO: ', old.personal_medico_id, '-', NEW.personal_medico_id, '\n',
'PACIENTE: ',old.paciente, '-', NEW.paciente,'\n',
'NIVEL_URGENCIA: ', old.nivel_urgencia, '-', NEW.nivel_urgencia,'\n',
'HORARIO: ', old.horario, '-', NEW.horario,'\n',
'OBSERVACIONES: ', old.observaciones, '-', NEW.observaciones,'\n',
'FECHA_REGISTRO ', old.fecha_registro, '-', NEW.fecha_registro,'\n',
'VALORACION_MEDICA: ', old.fecha_registro, '-', NEW.valoracion_medica, '\n',
'ESTATUS:', old.estatus, '-', NEW.estatus, '\n',
'CONSUMIBLE: ', old.consumible, '-' , NEW.consumible,'\n',
'ESPACIO_MEDICO: ', old.espacio_medico_id, '-', NEW.espacio_medico_id,'\n'
),
default,
default
);



END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`brayan.gutierrez`@`%`*/ /*!50003 TRIGGER `tbb_cirugias_AFTER_DELETE` AFTER DELETE ON `tbb_cirugias` FOR EACH ROW BEGIN
insert into tbi_bitacora values(
    default,
    current_user(),
    'Delete',
    'tbb_cirugias',
    concat_ws(' ','Se ha eliminado una cirugia con los siguientes datos: ',
    'TIPO: ', old.tipo,'\n',
    'NOMBRE: ', old.nombre,'\n',
    'DESCRIPCION: ', old.descripcion,'\n',
    'PERSONAL MÉDICO: ', old.personal_medico_id,'\n',
    'PACIENTE: ', old.paciente,'\n',
    'NIVEL URGENCIA: ', old.nivel_urgencia,'\n',
    'HORARIO: ', old.horario,'\n',
    'OBSERVACIONES: ', old.observaciones,'\n',
    'FECHA REGISTRO: ', old.fecha_registro,'\n',
    'VALORACIÓN MÉDICA: ', old.valoracion_medica,'\n',
    'ESTATUS: ', old.estatus,'\n',
    'CONSUMIBLE: ', old.consumible,'\n',
    'ESPACIO MÉDICO: ', old.espacio_medico_id,'\n',
    'FECHA ACTUALIZACIÓN: ', old.fecha_actualizacion
    ),
    default,
    default
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbb_citas_medicas`
--

DROP TABLE IF EXISTS `tbb_citas_medicas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_citas_medicas` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Personal_Medico_ID` int unsigned NOT NULL,
  `Paciente_ID` int unsigned NOT NULL,
  `Servicio_Medico_ID` int unsigned NOT NULL,
  `Folio` varchar(60) NOT NULL,
  `Tipo` enum('Revisión','Diagnóstico','Tratamiento','Rehabilitación','Preoperatoria','Postoperatoria','Proceminientos','Seguimiento') NOT NULL,
  `Espacio_ID` int unsigned NOT NULL,
  `Fecha_Programada` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Inicio` datetime DEFAULT NULL,
  `Fecha_Termino` datetime DEFAULT NULL,
  `Observaciones` text NOT NULL,
  `Estatus` enum('Programada','Atendida','Cancelada','Reprogramada','No atendida','En proceso') NOT NULL DEFAULT 'Programada',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Folio_UNIQUE` (`Folio`),
  KEY `fk_personal_medico_2_idx` (`Personal_Medico_ID`),
  KEY `fk_paciente_2_idx` (`Paciente_ID`),
  KEY `fk_servicio_medico_1_idx` (`Servicio_Medico_ID`),
  CONSTRAINT `fk_paciente_2` FOREIGN KEY (`Paciente_ID`) REFERENCES `tbb_pacientes` (`Persona_ID`),
  CONSTRAINT `fk_personal_medico_2` FOREIGN KEY (`Personal_Medico_ID`) REFERENCES `tbb_personal_medico` (`Persona_ID`),
  CONSTRAINT `fk_servicio_medico_1` FOREIGN KEY (`Servicio_Medico_ID`) REFERENCES `tbc_servicios_medicos` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_citas_medicas`
--

LOCK TABLES `tbb_citas_medicas` WRITE;
/*!40000 ALTER TABLE `tbb_citas_medicas` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbb_citas_medicas` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`janeth.ahuacatitla`@`%`*/ /*!50003 TRIGGER `tbb_citas_medicas_BEFORE_INSERT` BEFORE INSERT ON `tbb_citas_medicas` FOR EACH ROW BEGIN
	set new.folio = UUID(); 
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`janeth.ahuacatitla`@`%`*/ /*!50003 TRIGGER `tbb_citas_medicas_BEFORE_UPDATE` BEFORE UPDATE ON `tbb_citas_medicas` FOR EACH ROW BEGIN
	set new.fecha_actualizacion = current_timestamp(); 
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbb_nacimientos`
--

DROP TABLE IF EXISTS `tbb_nacimientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_nacimientos` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Padre` varchar(100) NOT NULL,
  `Madre` varchar(100) NOT NULL,
  `Signos_vitales` varchar(10) NOT NULL,
  `Estatus` bit(1) NOT NULL DEFAULT b'1',
  `Calificacion_APGAR` int NOT NULL,
  `Observaciones` varchar(45) NOT NULL,
  `Genero` enum('M','F') NOT NULL,
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_nacimientos`
--

LOCK TABLES `tbb_nacimientos` WRITE;
/*!40000 ALTER TABLE `tbb_nacimientos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbb_nacimientos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`eli.aidan`@`%`*/ /*!50003 TRIGGER `tbb_nacimientos_AFTER_INSERT` AFTER INSERT ON `tbb_nacimientos` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora 
    VALUES ( default,
        current_user(), 
        'Create',
        'tbb_nacimientos', 
        CONCAT_WS('', 
            'Se ha agregado un nuevo registro en tbb_nacimientos con el ID: ', NEW.ID,
            ', con los siguientes datos; ',
            'Nombre del Padre: ', NEW.Padre,
            ', Nombre de la Madre: ', NEW.Madre,
            ', Signos Vitales: ', NEW.Signos_vitales,
            ', Estatus: ', NEW.Estatus,
            ', Calificación APGAR: ', NEW.Calificacion_APGAR,
            ', Observaciones: ', NEW.Observaciones,
            ', Genero: ', NEW.Genero
        ), 
        default,
        default
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`eli.aidan`@`%`*/ /*!50003 TRIGGER `tbb_nacimientos_BEFORE_UPDATE` BEFORE UPDATE ON `tbb_nacimientos` FOR EACH ROW BEGIN
	SET new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`eli.aidan`@`%`*/ /*!50003 TRIGGER `tbb_nacimientos_AFTER_UPDATE` AFTER UPDATE ON `tbb_nacimientos` FOR EACH ROW BEGIN
	INSERT INTO tbi_bitacora 
    VALUES ( default,
		current_user(),
        'Update', 
        'tbb_nacimientos', 
        CONCAT_WS('', 
            'Se ha actualizado el registro en tbb_nacimientos con el ID: ', NEW.ID,
            ', con los siguientes datos actualizados; ',
            'Nombre del Padre: ', NEW.Padre,
            ', Nombre de la Madre: ', NEW.Madre,
            ', Signos Vitales: ', NEW.Signos_vitales,
            ', Estatus: ', NEW.Estatus,
            ', Calificación APGAR: ', NEW.Calificacion_APGAR,
            ', Observaciones: ', NEW.Observaciones,
            ', Genero: ', NEW.Genero
        ), 
        default,
        default
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`eli.aidan`@`%`*/ /*!50003 TRIGGER `tbb_nacimientos_AFTER_DELETE` AFTER DELETE ON `tbb_nacimientos` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora
    VALUES ( default,
		current_user(),
        'Delete', 
        'tbb_nacimientos',
        CONCAT_WS('', 
            'Se ha eliminado un registro en tbb_nacimientos con el ID: ', OLD.ID,
            ', que contenía los siguientes datos; ',
            'Nombre del Padre: ', OLD.Padre,
            ', Nombre de la Madre: ', OLD.Madre,
            ', Signos Vitales: ', OLD.Signos_vitales,
            ', Estatus: ', OLD.Estatus,
            ', Calificación APGAR: ', OLD.Calificacion_APGAR,
            ', Observaciones: ', OLD.Observaciones,
            ', Genero: ', OLD.Genero
        ), 
        default,
        default
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbb_pacientes`
--

DROP TABLE IF EXISTS `tbb_pacientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_pacientes` (
  `Persona_ID` int unsigned NOT NULL,
  `NSS` varchar(15) DEFAULT NULL,
  `Tipo_Seguro` varchar(50) NOT NULL,
  `Fecha_Ultima_Cita` datetime DEFAULT NULL,
  `Estatus_Medico` varchar(100) DEFAULT 'Normal',
  `Estatus_Vida` enum('Vivo','Finado','Coma','Vegetativo') NOT NULL DEFAULT 'Vivo',
  `Estatus` binary(1) DEFAULT '',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`Persona_ID`),
  UNIQUE KEY `NSS_UNIQUE` (`NSS`),
  CONSTRAINT `fk_pacientes_1` FOREIGN KEY (`Persona_ID`) REFERENCES `tbb_personas` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='	';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_pacientes`
--

LOCK TABLES `tbb_pacientes` WRITE;
/*!40000 ALTER TABLE `tbb_pacientes` DISABLE KEYS */;
INSERT INTO `tbb_pacientes` VALUES (5,NULL,'Sin Seguro','2009-03-17 17:31:00','Normal','Vivo',_binary '1','2001-02-15 06:23:05',NULL),(6,NULL,'Sin Seguro','2019-05-01 13:15:29','Normal','Vivo',_binary '1','2020-06-28 18:46:37',NULL),(8,'12254185844-3','Particular','2022-08-16 12:05:35','Normal','Vivo',_binary '1','2022-08-16 11:50:00',NULL);
/*!40000 ALTER TABLE `tbb_pacientes` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`justin.muñoz`@`%`*/ /*!50003 TRIGGER `tbb_pacientes_AFTER_INSERT` AFTER INSERT ON `tbb_pacientes` FOR EACH ROW BEGIN
	  declare v_estatus varchar(20) default 'Activo';
      
		if not new.Estatus then
			set v_estatus = 'Inactivo';
		end if;
      
      insert into tbi_bitacora values(
		default,
		current_user(),
		'Create',
		'tbb_pacientes',
		concat_ws(' ','Se ha creado un nuevo paciente con los siguientes datos: \n',
		'NSS: ', new.NSS, '\n', 
		'TIPO SEGURO: ', new.Tipo_Seguro, '\n', 
		'ESTATUS MEDICO: ', new.Estatus_Medico, '\n', 
		'ESTATUS VIDA: ', new.Estatus_Vida, '\n',
        'ESTATUS: ', v_estatus, '\n'),
		default,
		default
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`justin.muñoz`@`%`*/ /*!50003 TRIGGER `tbb_pacientes_BEFORE_UPDATE` BEFORE UPDATE ON `tbb_pacientes` FOR EACH ROW BEGIN
	set new.fecha_actualizacion = current_timestamp(); 
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`justin.muñoz`@`%`*/ /*!50003 TRIGGER `tbb_pacientes_AFTER_UPDATE` AFTER UPDATE ON `tbb_pacientes` FOR EACH ROW BEGIN
	 declare v_estatus_old varchar(20) default 'Activo';
     declare v_estatus_new varchar(20) default 'Activo';
      
		if not new.Estatus then
			set v_estatus_new = 'Inactivo';
		end if;
        if not new.Estatus then
			set v_estatus_old = 'Inactivo';
		end if;
        
    
    insert into tbi_bitacora values(
			default,
			current_user(),
			'Update',
			'tbb_pacientes',
			concat_ws(' ','Se ha creado un modificado al paciente con NSS: ',old.NSS,'con los siguientes datos: \n',
			'NSS: ', old.NSS,' -> ',new.NSS, '\n', 
			'TIPO SEGURO: ', old.Tipo_Seguro,' -> ',new.Tipo_Seguro, '\n', 
			'ESTATUS MEDICO: ', old.Estatus_Medico,' -> ',new.Estatus_Medico, '\n', 
			'ESTATUS VIDA: ', old.	Estatus_Vida,' -> ',new.Estatus_Vida, '\n',
            'ESTATUS: ', v_estatus_old, '->',v_estatus_new, '\n'),
			default,
			default
		);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`justin.muñoz`@`%`*/ /*!50003 TRIGGER `tbb_pacientes_AFTER_DELETE` AFTER DELETE ON `tbb_pacientes` FOR EACH ROW BEGIN
	declare v_estatus varchar(20) default 'Activo';
      
		if not old.Estatus then
			set v_estatus = 'Inactivo';
		end if;
    
    insert into tbi_bitacora values(
		default,
		current_user(),
		'Delete',
		'tbb_pacientes',
		concat_ws(' ','Se ha eliminado un paciente existente con NSS: ',old.NSS,'y con los siguientes datos: \n',
		'TIPO SEGURO: ', old.Tipo_Seguro, '\n', 
		'ESTATUS MEDICO: ', old.Estatus_Medico, '\n', 
		'ESTATUS VIDA: ', old.Estatus_Vida, '\n'
        'ESTATUS: ', v_estatus, '\n'),
		default,
		default
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbb_personal_medico`
--

DROP TABLE IF EXISTS `tbb_personal_medico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_personal_medico` (
  `Persona_ID` int unsigned NOT NULL,
  `Departamento_ID` int unsigned NOT NULL,
  `Cedula_Profesional` varchar(100) NOT NULL,
  `Tipo` enum('Médico','Enfermero','Administrativo','Directivo','Apoyo','Residente','Interno') NOT NULL,
  `Especialidad` varchar(255) DEFAULT NULL,
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Contratacion` datetime NOT NULL,
  `Fecha_Termino_Contrato` datetime DEFAULT NULL,
  `Salario` decimal(10,2) NOT NULL,
  `Estatus` enum('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  UNIQUE KEY `Cedula_Profesional` (`Cedula_Profesional`),
  KEY `Persona_ID_idx` (`Persona_ID`),
  KEY `Departamento_ID_idx` (`Departamento_ID`),
  CONSTRAINT `Departamento_ID` FOREIGN KEY (`Departamento_ID`) REFERENCES `tbc_departamentos` (`ID`),
  CONSTRAINT `Persona_ID` FOREIGN KEY (`Persona_ID`) REFERENCES `tbb_personas` (`ID`),
  CONSTRAINT `tbb_personal_medico_chk_1` CHECK ((`Salario` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_personal_medico`
--

LOCK TABLES `tbb_personal_medico` WRITE;
/*!40000 ALTER TABLE `tbb_personal_medico` DISABLE KEYS */;
INSERT INTO `tbb_personal_medico` VALUES (2,11,'11422587','Médico',NULL,'2018-05-10 08:50:25','2018-05-10 09:10:52',NULL,10000.00,'Activo',NULL),(1,13,'25515487','Médico','Pediatría','2012-08-22 08:50:25','2015-09-16 09:10:52',NULL,35000.00,'Activo',NULL),(3,1,'3256884','Administrativo',NULL,'2000-01-01 11:50:25','2000-01-02 09:00:00',NULL,45000.00,'Activo','2024-07-18 11:15:05');
/*!40000 ALTER TABLE `tbb_personal_medico` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`jonathan.ibarra`@`%`*/ /*!50003 TRIGGER `tbb_personal_medico_AFTER_INSERT` AFTER INSERT ON `tbb_personal_medico` FOR EACH ROW BEGIN
    DECLARE persona_nombre_completo VARCHAR(255);
    DECLARE departamento_nombre VARCHAR(255);

    -- Obtener el nombre completo de la persona
    SELECT CONCAT_WS(' ',Nombre, ' ', Primer_Apellido, ' ', Segundo_Apellido) 
    INTO persona_nombre_completo 
    FROM tbb_personas 
    WHERE ID = NEW.Persona_ID;
    
    -- Obtener el nombre del departamento
    SELECT nombre 
    INTO departamento_nombre 
    FROM tbc_departamentos 
    WHERE ID = NEW.Departamento_ID;

    -- Insertar en la bitácora
    INSERT INTO tbi_bitacora
    VALUES
    (
        DEFAULT,
        current_user(),
        'Create',
        'tbb_personal_medico',
        CONCAT_WS(' ',
            'Se ha creado nuevo personal medico con los siguientes datos:', '\n',
            'Nombre de la Persona: ', persona_nombre_completo, '\n',
            'Nombre del Departamento: ', departamento_nombre, '\n',
            'Especialidad: ', NEW.Especialidad, '\n',
            'Tipo: ', NEW.Tipo, '\n',
            'Cedula Profesional: ', NEW.Cedula_Profesional, '\n',
            'Estatus: ', NEW.Estatus, '\n',
            'Fecha de Contratación: ', NEW.Fecha_Contratacion, '\n',
            'Salario: ', NEW.Salario, '\n',
            'Fecha de Actualización: ', NEW.Fecha_Actualizacion, '\n'
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`jonathan.ibarra`@`%`*/ /*!50003 TRIGGER `tbb_personal_medico_BEFORE_UPDATE` BEFORE UPDATE ON `tbb_personal_medico` FOR EACH ROW BEGIN
	SET new.Fecha_Actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`jonathan.ibarra`@`%`*/ /*!50003 TRIGGER `tbb_personal_medico_AFTER_UPDATE` AFTER UPDATE ON `tbb_personal_medico` FOR EACH ROW BEGIN
 DECLARE old_persona_nombre_completo VARCHAR(255);
    DECLARE new_persona_nombre_completo VARCHAR(255);
    DECLARE old_departamento_nombre VARCHAR(255);
    DECLARE new_departamento_nombre VARCHAR(255);

    -- Obtener el nombre completo de la persona antes de la actualización
    SELECT CONCAT_WS(' ', Nombre, ' ', Primer_Apellido, ' ', Segundo_Apellido) 
    INTO old_persona_nombre_completo 
    FROM tbb_personas 
    WHERE ID = OLD.Persona_ID;
    
    -- Obtener el nombre completo de la persona después de la actualización
    SELECT CONCAT_WS(' ', Nombre, ' ', Primer_Apellido, ' ', Segundo_Apellido) 
    INTO new_persona_nombre_completo 
    FROM tbb_personas 
    WHERE ID = NEW.Persona_ID;

    -- Obtener el nombre del departamento antes de la actualización
    SELECT nombre 
    INTO old_departamento_nombre 
    FROM tbc_departamentos 
    WHERE ID = OLD.Departamento_ID;
    
    -- Obtener el nombre del departamento después de la actualización
    SELECT nombre 
    INTO new_departamento_nombre 
    FROM tbc_departamentos 
    WHERE ID = NEW.Departamento_ID;

    -- Insertar en la bitácora
    INSERT INTO tbi_bitacora
    VALUES
    (
        DEFAULT,
        current_user(),
        'Update',
        'tbb_personal_medico',
        concat_ws(' ',
            'Se ha modificado el personal médico con los siguientes datos:', '\n',
            'Nombre de la Persona: ', old_persona_nombre_completo, ' -> ', new_persona_nombre_completo, '\n',
            'Nombre del Departamento: ', old_departamento_nombre, ' -> ', new_departamento_nombre, '\n',
            'Especialidad: ', OLD.Especialidad, ' -> ', NEW.Especialidad, '\n',
            'Tipo: ', OLD.Tipo, ' -> ', NEW.Tipo, '\n',
            'Cédula Profesional: ', OLD.Cedula_Profesional, ' -> ', NEW.Cedula_Profesional, '\n',
            'Estatus: ', OLD.Estatus, ' -> ', NEW.Estatus, '\n',
            'Fecha de Contratación: ', OLD.Fecha_Contratacion, ' -> ', NEW.Fecha_Contratacion, '\n',
            'Salario: ', OLD.Salario, ' -> ', NEW.Salario, '\n'
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`jonathan.ibarra`@`%`*/ /*!50003 TRIGGER `tbb_personal_medico_AFTER_DELETE` AFTER DELETE ON `tbb_personal_medico` FOR EACH ROW BEGIN
 DECLARE persona_nombre_completo VARCHAR(255);
    DECLARE departamento_nombre VARCHAR(255);

    -- Obtener el nombre completo de la persona
    SELECT CONCAT_WS(' ', Nombre, ' ', Primer_Apellido, ' ', Segundo_Apellido) 
    INTO persona_nombre_completo 
    FROM tbb_personas 
    WHERE ID = OLD.Persona_ID;
    
    -- Obtener el nombre del departamento
    SELECT nombre 
    INTO departamento_nombre 
    FROM tbc_departamentos 
    WHERE ID = OLD.Departamento_ID;

    -- Insertar en la bitácora
    INSERT INTO tbi_bitacora VALUES
    (
        DEFAULT,
        current_user(),
        'Delete',
        'tbb_personal_medico',
        CONCAT_WS(' ',
            'Se ha eliminado personal médico existente con los siguientes datos:',
            '\nNombre de la Persona: ', persona_nombre_completo,
            '\nNombre del Departamento: ', departamento_nombre,
            '\nEspecialidad: ', OLD.Especialidad,
            '\nTipo: ', OLD.Tipo,
            'Cédula Profesional: ', OLD.Cedula_Profesional,
            '\nEstatus: ', OLD.Estatus,
            '\nFecha de Contratación: ', OLD.Fecha_Contratacion,
            '\nSalario: ', OLD.Salario
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbb_personas`
--

DROP TABLE IF EXISTS `tbb_personas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_personas` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Titulo` varchar(20) DEFAULT NULL,
  `Nombre` varchar(80) NOT NULL,
  `Primer_Apellido` varchar(80) NOT NULL,
  `Segundo_Apellido` varchar(80) DEFAULT NULL,
  `CURP` varchar(18) DEFAULT NULL,
  `Genero` enum('M','F','N/B') NOT NULL,
  `Grupo_Sanguineo` enum('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
  `Fecha_Nacimiento` date NOT NULL,
  `Estatus` bit(1) NOT NULL DEFAULT b'1',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `CURP_UNIQUE` (`CURP`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_personas`
--

LOCK TABLES `tbb_personas` WRITE;
/*!40000 ALTER TABLE `tbb_personas` DISABLE KEYS */;
INSERT INTO `tbb_personas` VALUES (1,'Dr.','Alejandro','Barrera','Fernández','BAFA810525HVZLRR05','M','O+','1981-05-25',_binary '','2024-07-18 11:15:05',NULL),(2,'Dra.','María José','Álvarez','Fonseca','ALFM900620MPLLNR2A','F','O-','1990-06-20',_binary '','2024-07-18 11:15:05',NULL),(3,'Dr.','Alfredo','Carrasco','Lechuga','CALA710115HCSRCL25','M','AB-','1971-01-15',_binary '','2024-07-18 11:15:05',NULL),(4,'Lic.','Fernanda','García','Méndez','ABCD','N/B','A+','1995-05-10',_binary '','2024-07-18 11:15:05',NULL),(5,'Sra.','María','López','Martínez','LOMJ850202MDFRPL01','F','A+','1985-02-02',_binary '','2024-07-18 11:15:06',NULL),(6,NULL,'Ana','Hernández','Ruiz','HERA900303HDFRRL01','F','B+','1990-03-03',_binary '','2024-07-18 11:15:06',NULL),(7,'Dr.','Carlos','García','Rodríguez','GARC950404HDFRRL06','M','AB+','1995-04-04',_binary '','2024-07-18 11:15:06',NULL),(8,'Lic.','Laura','Martínez','Gómez','MALG000505MDFRRL07','F','O-','2000-05-05',_binary '','2024-07-18 11:15:06',NULL);
/*!40000 ALTER TABLE `tbb_personas` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`jose.gomez`@`%`*/ /*!50003 TRIGGER `tbb_personas_AFTER_INSERT` AFTER INSERT ON `tbb_personas` FOR EACH ROW BEGIN
   DECLARE nombre_persona VARCHAR(255);
declare v_estatus varchar(20) default 'Activo';
-- validamos el estatus del registro y le asignamos una etiqueta para la descripcion

	if not new.Estatus then
		set v_estatus = 'Inactivo';
    end if;

    -- Obtain the name of the newly inserted person
    SET nombre_persona = (SELECT CONCAT_WS(" ", p.Nombre, p.Primer_Apellido, p.Segundo_Apellido)
                         FROM tbb_personas p
                         WHERE p.id = NEW.ID);

    -- Register the insertion of a new person in the logbook
    INSERT INTO tbi_bitacora VALUES (
       DEFAULT, current_user(), 'Create','tbb_personas',
       CONCAT_WS(" ", 'Se ha agregado una nueva PERSONA con el ID: ', NEW.ID,'\n',
                 'Nombre: ', nombre_persona,'\n',
                 'Titulo: ', NEW.Titulo,'\n',
                 'Primer Apellido: ', NEW.Primer_Apellido,'\n',
                 'Segundo Apellido: ', NEW.Segundo_Apellido,'\n',
                 'CURP: ', NEW.CURP,'\n',
                 'Genero: ', NEW.Genero,'\n',
                 'Grupo Sanguineo: ', NEW.Grupo_Sanguineo,'\n',
                 'Fecha de Nacimiento: ', NEW.Fecha_Nacimiento,'\n',
                 'Estatus: ', v_estatus),
       default,default
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`jose.gomez`@`%`*/ /*!50003 TRIGGER `tbb_personas_AFTER_UPDATE` AFTER UPDATE ON `tbb_personas` FOR EACH ROW BEGIN
 DECLARE nombre_persona_old VARCHAR(255);
    DECLARE nombre_persona_new VARCHAR(255);
    DECLARE v_estatus_old VARCHAR(20) DEFAULT 'Activo';
    DECLARE v_estatus_new VARCHAR(20) DEFAULT 'Activo';

    -- Validamos el estatus del registro antiguo y nuevo y les asignamos una etiqueta para la descripción
    IF NOT OLD.Estatus THEN
        SET v_estatus_old = 'Inactivo';
    END IF;

    IF NOT NEW.Estatus THEN
        SET v_estatus_new = 'Inactivo';
    END IF;

    -- Obtener el nombre de la persona antes y después de la actualización
    SET nombre_persona_old = CONCAT_WS(" ", OLD.Nombre, OLD.Primer_Apellido, OLD.Segundo_Apellido);
    SET nombre_persona_new = CONCAT_WS(" ", NEW.Nombre, NEW.Primer_Apellido, NEW.Segundo_Apellido);

    -- Registrar en la bitácora la actualización de una persona
    INSERT INTO tbi_bitacora (
    ) VALUES (
        DEFAULT, 
        CURRENT_USER(), 
        'Update',
        'tbb_personas',
        CONCAT_WS(
            " ",
            'Se ha actualizado los datos de la PERSONA con el ID:', OLD.ID, '\n',
            'Nombre Antiguo:', nombre_persona_old, '\n',
            'Nombre Nuevo:', nombre_persona_new, '\n',
            'Titulo:', NEW.Titulo, '\n',
            'Primer Apellido:', NEW.Primer_Apellido, '\n',
            'Segundo Apellido:', NEW.Segundo_Apellido, '\n',
            'CURP:', NEW.CURP, '\n',
            'Genero:', NEW.Genero, '\n',
            'Grupo Sanguineo:', NEW.Grupo_Sanguineo, '\n',
            'Fecha de Nacimiento:', NEW.Fecha_Nacimiento, '\n',
            'Estatus Antiguo:', v_estatus_old, '\n',
            'Estatus Nuevo:', v_estatus_new
        ),
        default,default
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`jose.gomez`@`%`*/ /*!50003 TRIGGER `tbb_personas_AFTER_DELETE` AFTER DELETE ON `tbb_personas` FOR EACH ROW BEGIN
    DECLARE v_estatus VARCHAR(20) DEFAULT 'Activo';
    
    -- Validamos el estatus del registro y le asignamos una etiqueta para la descripción
    IF NOT OLD.Estatus THEN
        SET v_estatus = 'Inactivo';
    END IF;

    -- Registrar en la bitácora la eliminación de una persona
    INSERT INTO tbi_bitacora VALUES (
        DEFAULT, 
        CURRENT_USER(), 
        'Delete', 
        'tbb_personas', 
        CONCAT_WS(
            ' ', 
            'Se ha eliminado la PERSONA con el ID:', OLD.ID, '\n'
            'Nombre:', OLD.Nombre, '\n'
            'Primer Apellido:', OLD.Primer_Apellido, '\n'
            'Segundo Apellido:', OLD.Segundo_Apellido, '\n'
            'CURP:', OLD.CURP, '\n'
            'Genero:', OLD.Genero, '\n',
            'Grupo Sanguineo:', OLD.Grupo_Sanguineo, '\n'
            'Fecha de Nacimiento:', OLD.Fecha_Nacimiento, '\n'
            'Estatus:', v_estatus
        ),
        default, default
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbb_usuarios`
--

DROP TABLE IF EXISTS `tbb_usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_usuarios` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Persona_ID` int unsigned NOT NULL,
  `Nombre_Usuario` varchar(60) NOT NULL,
  `Correo_Electronico` varchar(100) NOT NULL,
  `Contrasena` varchar(40) NOT NULL,
  `Numero_Telefonico_Movil` char(19) NOT NULL,
  `Estatus` enum('Activo','Inactivo','Bloqueado','Suspendido') DEFAULT NULL,
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Correo_Electronico_UNIQUE` (`Correo_Electronico`),
  UNIQUE KEY `Nombre_Usuario_UNIQUE` (`Nombre_Usuario`),
  UNIQUE KEY `Numero_Telefonico_Movil_UNIQUE` (`Numero_Telefonico_Movil`),
  KEY `fk_Personas_2_idx` (`Persona_ID`),
  CONSTRAINT `fk_Personas_2` FOREIGN KEY (`Persona_ID`) REFERENCES `tbb_personas` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_usuarios`
--

LOCK TABLES `tbb_usuarios` WRITE;
/*!40000 ALTER TABLE `tbb_usuarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbb_usuarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_usuarios_AFTER_INSERT` AFTER INSERT ON `tbb_usuarios` FOR EACH ROW BEGIN

	INSERT INTO tbi_bitacora VALUES
    (DEFAULT,
    current_user(), 
    'Create', 
    'tbb_usuarios', 
    CONCAT_WS(' ','Se ha creado un nuevo usuario con los siguientes datos:',
    'ID: ', new.id, '\n',
    'PERSONA ID: ', new.persona_id, '\n',
    'NOMBRE USUARIO: ', new.nombre_usuario, '\n',
    'CORREO ELECTRÓNICO: ', new.correo_electronico, '\n',
    'CONTRASEÑA: ', new.contrasena, '\n',
    'NÚMERO TELEFÓNICO MÓVIL: ', new.numero_telefonico_movil, '\n',
    'ESTATUS: ', new.estatus, '\n'),
    DEFAULT, DEFAULT);

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_usuarios_BEFORE_UPDATE` BEFORE UPDATE ON `tbb_usuarios` FOR EACH ROW BEGIN
	SET new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_usuarios_AFTER_UPDATE` AFTER UPDATE ON `tbb_usuarios` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora VALUES
    (DEFAULT,
    current_user(), 
    'Update', 
    'tbb_usuarios', 
    CONCAT_WS(' ','Se ha creado un modificado ul usuario con ID :', old.id,"con los 
    siguientes datos: \n",
    'PERSONA ID: ', old.persona_id, ' - ', new.persona_id, '\n',
    'NOMBRE USUARIO: ', old.nombre_usuario, ' - ', new.nombre_usuario, '\n',
    'CORREO ELECTRÓNICO: ', old.correo_electronico, ' - ',new.correo_electronico, '\n',
    'CONTRASEÑA: ', old.contrasena, ' - ',new.contrasena, '\n',
    'NÚMERO TELEFÓNICO MÓVIL: ', old.numero_telefonico_movil, ' - ',new.numero_telefonico_movil, '\n',
    'ESTATUS: ', old.estatus, ' - ',new.estatus, '\n'),
    DEFAULT, DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_usuarios_AFTER_DELETE` AFTER DELETE ON `tbb_usuarios` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora VALUES
    (DEFAULT,
    current_user(), 
    'Delete', 
    'tbb_usuarios', 
    CONCAT_WS(' ','Se ha eliminado un usuario existente con los siguientes datos:',
    'ID: ', old.id, '\n',
    'PERSONA ID: ', old.persona_id, '\n',
    'NOMBRE USUARIO: ', old.nombre_usuario, '\n',
    'CORREO ELECTRÓNICO: ', old.correo_electronico, '\n',
    'CONTRASEÑA: ', old.contrasena, '\n',
    'NÚMERO TELEFÓNICO MÓVIL: ', old.numero_telefonico_movil, '\n',
    'ESTATUS: ', old.estatus, '\n'),
    DEFAULT, DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbb_valoraciones_medicas`
--

DROP TABLE IF EXISTS `tbb_valoraciones_medicas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_valoraciones_medicas` (
  `id` int NOT NULL,
  `paciente_id` int DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `antecedentes_personales` text,
  `antecedentes_familiares` text,
  `antecedentes_medicos` text,
  `sintomas_signos` text,
  `examen_fisico` text,
  `pruebas_diagnosticas` text,
  `diagnostico` text,
  `plan_tratamiento` text,
  `seguimiento` text,
  `fecha_actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_valoraciones_medicas`
--

LOCK TABLES `tbb_valoraciones_medicas` WRITE;
/*!40000 ALTER TABLE `tbb_valoraciones_medicas` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbb_valoraciones_medicas` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`romualdo`@`localhost`*/ /*!50003 TRIGGER `tbb_valoraciones_medicas_AFTER_INSERT` AFTER INSERT ON `tbb_valoraciones_medicas` FOR EACH ROW BEGIN
    INSERT INTO tbi_bitacora (
        id,
        usuario,
        operacion,
        tabla,
        descripcion
    ) VALUES (
        default,
        current_user(),
        'Create',
        'tbb_valoraciones_medicas',
        concat_ws('', 
            'Se ha registrado una nueva valoracion medica con los siguientes datos:', 
            'Id: ', NEW.id,'\n',
            'Paciente: ', NEW.paciente_id,'\n',
            'Fecha: ', NEW.fecha,'\n',
            'Antecedentes Personales: ', NEW.antecedentes_personales,'\n',
            'Antecedentes Familiares: ', NEW.antecedentes_familiares,'\n',
            'Antecedentes Medicos: ', NEW.antecedentes_medicos,'\n',
            'Sintomas y Signos: ', NEW.sintomas_signos,'\n',
            'Examen Fisico: ', NEW.examen_fisico,'\n',
            'Pruebas Diagnosticas: ', NEW.pruebas_diagnosticas,'\n',
            'Diagnostico: ', NEW.diagnostico,'\n',
            'Plan de Tratamiento: ', NEW.plan_tratamiento,'\n',
            'Seguimiento: ', NEW.seguimiento)
            
            
            
            
            
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`romualdo`@`localhost`*/ /*!50003 TRIGGER `tbb_valoraciones_medicas_BEFORE_UPDATE` BEFORE UPDATE ON `tbb_valoraciones_medicas` FOR EACH ROW SET new.fecha_actualizacion = current_timestamp() */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`romualdo`@`localhost`*/ /*!50003 TRIGGER `tbb_valoraciones_medicas_AFTER_UPDATE` AFTER UPDATE ON `tbb_valoraciones_medicas` FOR EACH ROW BEGIN

    INSERT INTO tbi_bitacora (
        id,
        usuario,
        operacion,
        tabla,
        descripcion
    ) VALUES (
        default,
        current_user(),
        'update',
        'tbb_valoraciones_medicas',
        concat_ws('', 
            'Se ha modificado al usuario con ID: ',old.id, "con los 
        siguientes datos \n",
			'Paciente: ', OLD.paciente_id, ' -> ', NEW.paciente_id, '\n',
            'Fecha: ', OLD.fecha, ' -> ', NEW.fecha, '\n',
            'Antecedentes Personales: ', OLD.antecedentes_personales, ' -> ', NEW.antecedentes_personales, '\n',
            'Antecedentes Familiares: ', OLD.antecedentes_familiares, ' -> ', NEW.antecedentes_familiares, '\n',
            'Antecedentes Medicos: ', OLD.antecedentes_medicos, ' -> ', NEW.antecedentes_medicos, '\n',
            'Sintomas y Signos: ', OLD.sintomas_signos, ' -> ', NEW.sintomas_signos, '\n',
            'Examen Fisico: ', OLD.examen_fisico, ' -> ', NEW.examen_fisico, '\n',
            'Pruebas Diagnosticas: ', OLD.pruebas_diagnosticas, ' -> ', NEW.pruebas_diagnosticas, '\n',
            'Diagnostico: ', OLD.diagnostico, ' -> ', NEW.diagnostico, '\n',
            'Plan de Tratamiento: ', OLD.plan_tratamiento, ' -> ', NEW.plan_tratamiento, '\n',
            'Seguimiento: ', OLD.seguimiento, ' -> ', NEW.seguimiento)
            
            
            
            
            
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`romualdo`@`localhost`*/ /*!50003 TRIGGER `tbb_valoraciones_medicas_AFTER_DELETE` AFTER DELETE ON `tbb_valoraciones_medicas` FOR EACH ROW BEGIN
    INSERT INTO tbi_bitacora (
        id,
        usuario,
        operacion,
        tabla,
        descripcion
    ) VALUES (
        default,
        current_user(),
        'Delete',
        'tbb_valoraciones_medicas',
        concat_ws('', 
            'Se ha eliminado una valoracion medica con los siguientes datos:', 
            'Id: ', old.id,'\n',
            'Paciente: ', old.paciente_id,'\n',
            'Fecha: ', old.fecha,'\n',
            'Antecedentes Personales: ', old.antecedentes_personales,'\n',
            'Antecedentes Familiares: ', old.antecedentes_familiares,'\n',
            'Antecedentes Medicos: ', old.antecedentes_medicos,'\n',
            'Sintomas y Signos: ', old.sintomas_signos,'\n',
            'Examen Fisico: ', old.examen_fisico,'\n',
            'Pruebas Diagnosticas: ', old.pruebas_diagnosticas,'\n',
            'Diagnostico: ', old.diagnostico,'\n',
            'Plan de Tratamiento: ', old.plan_tratamiento,'\n',
            'Seguimiento: ', old.seguimiento)
            
            
            
            
            
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_areas_medicas`
--

DROP TABLE IF EXISTS `tbc_areas_medicas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_areas_medicas` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(150) NOT NULL,
  `Descripcion` text,
  `Estatus` enum('Activo','Inactivo') DEFAULT 'Activo',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_areas_medicas`
--

LOCK TABLES `tbc_areas_medicas` WRITE;
/*!40000 ALTER TABLE `tbc_areas_medicas` DISABLE KEYS */;
INSERT INTO `tbc_areas_medicas` VALUES (1,'Servicios Medicos','Por definir','Activo','2024-01-21 16:00:41','2024-06-20 09:38:36'),(2,'Servicios de Apoyo','Por definir','Activo','2024-01-21 16:06:31','2024-06-20 09:38:36'),(3,'Servicios Medico - Administrativos','Por definir','Activo','2024-01-21 16:06:31','2024-06-20 09:38:36'),(4,'Servicios de Enfermeria','Por definir','Activo','2024-01-21 16:06:31','2024-06-20 09:38:36'),(5,'Departamentos Administrativos','Por definir','Activo','2024-01-21 16:06:31','2024-06-20 09:38:36');
/*!40000 ALTER TABLE `tbc_areas_medicas` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`america.estudillo`@`%`*/ /*!50003 TRIGGER `tbc_areas_medicas_AFTER_INSERT` AFTER INSERT ON `tbc_areas_medicas` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro)
    VALUES (
        CURRENT_USER(),
        'Create',
        'tbc_areas_medicas',
        CONCAT('Se ha creado una nueva área médica con los siguientes datos:',
            '\nID: ', NEW.ID,
            '\nNombre: ', NEW.Nombre,
            '\nDescripción: ', NEW.Descripcion,
            '\nEstatus: ', NEW.Estatus,
            '\nFecha de Registro: ', NEW.Fecha_Registro),
        1,
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`america.estudillo`@`%`*/ /*!50003 TRIGGER `tbc_areas_medicas_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_areas_medicas` FOR EACH ROW BEGIN
	set new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`america.estudillo`@`%`*/ /*!50003 TRIGGER `tbc_areas_medicas_AFTER_UPDATE` AFTER UPDATE ON `tbc_areas_medicas` FOR EACH ROW BEGIN
   IF OLD.Nombre != NEW.Nombre OR OLD.Descripcion != NEW.Descripcion OR OLD.Estatus != NEW.Estatus THEN
        INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro)
        VALUES (
            CURRENT_USER(),
            'Update',
            'tbc_areas_medicas',
            CONCAT('Se ha actualizado un área médica. Detalles de la actualización:',
                '\nID: ', NEW.ID,
                '\nNombre Anterior: ', OLD.Nombre,
                '\nNuevo Nombre: ', NEW.Nombre,
                '\nDescripción Anterior: ', OLD.Descripcion,
                '\nNueva Descripción: ', NEW.Descripcion,
                '\nEstatus Anterior: ', OLD.Estatus,
                '\nNuevo Estatus: ', NEW.Estatus,
                '\nFecha de Actualización: ', NOW()),
            1,
            NOW()
        );
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`america.estudillo`@`%`*/ /*!50003 TRIGGER `tbc_areas_medicas_AFTER_DELETE` AFTER DELETE ON `tbc_areas_medicas` FOR EACH ROW BEGIN
 INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro)
    VALUES (
        CURRENT_USER(),
        'Delete',
        'tbc_areas_medicas',
        CONCAT('Se ha eliminado un área médica. Detalles de la eliminación:',
            '\nID: ', OLD.ID,
            '\nNombre: ', OLD.Nombre,
            '\nDescripción: ', OLD.Descripcion,
            '\nEstatus: ', OLD.Estatus,
            '\nFecha de Registro: ', OLD.Fecha_Registro),
        1,
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_consumibles`
--

DROP TABLE IF EXISTS `tbc_consumibles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_consumibles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text NOT NULL,
  `tipo` varchar(50) NOT NULL,
  `departamento` varchar(50) NOT NULL,
  `cantidad_existencia` int NOT NULL,
  `detalle` text,
  `fecha_registro` datetime NOT NULL,
  `fecha_actualizacion` datetime NOT NULL,
  `estatus` bit(1) DEFAULT NULL,
  `observaciones` text,
  `espacio_medico` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_consumibles`
--

LOCK TABLES `tbc_consumibles` WRITE;
/*!40000 ALTER TABLE `tbc_consumibles` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbc_consumibles` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`daniela.aguilar`@`%`*/ /*!50003 TRIGGER `tbc_consumibles_AFTER_INSERT` AFTER INSERT ON `tbc_consumibles` FOR EACH ROW BEGIN
DECLARE v_estatus VARCHAR(20) DEFAULT 'Activo';

    IF NOT NEW.estatus THEN
        SET v_estatus = "Inactivo";
    END IF;

    INSERT INTO tbi_bitacora VALUES (
        DEFAULT,
        USER(),
        "Create",
        "tbc_consumibles",
        CONCAT_WS(" ", "Se ha insertado un nuevo consumible con los siguientes datos:",
            "NOMBRE =", NEW.nombre,
            "DESCRIPCION =", NEW.descripcion,
            "TIPO =", NEW.tipo,
            "DEPARTAMENTO =", NEW.departamento,
            "CANTIDAD EXISTENCIA =", NEW.cantidad_existencia,
            "DETALLE =", NEW.detalle,
            "FECHA DE REGISTRO =", NEW.fecha_registro,
            "ESTATUS =", v_estatus),
        DEFAULT,
        DEFAULT
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`daniela.aguilar`@`%`*/ /*!50003 TRIGGER `tbc_consumibles_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_consumibles` FOR EACH ROW BEGIN
SET NEW.fecha_actualizacion = CURRENT_TIMESTAMP();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`daniela.aguilar`@`%`*/ /*!50003 TRIGGER `tbc_consumibles_AFTER_UPDATE` AFTER UPDATE ON `tbc_consumibles` FOR EACH ROW BEGIN
DECLARE v_estatus_old VARCHAR(20) DEFAULT 'Activo';
    DECLARE v_estatus_new VARCHAR(20) DEFAULT 'Activo';

    IF NOT OLD.estatus THEN
        SET v_estatus_old = "Inactivo";
    END IF;
    IF NOT NEW.estatus THEN
        SET v_estatus_new = "Inactivo";
    END IF;

    INSERT INTO tbi_bitacora VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Update',
        'tbc_consumibles',
        CONCAT_WS(" ", "Se ha modificado un consumible existente con los siguientes datos:",
            "NOMBRE =", OLD.nombre, ' - ', NEW.nombre,
            "DESCRIPCION =", OLD.descripcion, ' - ', NEW.descripcion,
            "TIPO =", OLD.tipo, ' - ', NEW.tipo,
            "DEPARTAMENTO =", OLD.departamento, ' - ', NEW.departamento,
            "CANTIDAD EXISTENCIA =", OLD.cantidad_existencia, ' - ', NEW.cantidad_existencia,
            "DETALLE =", OLD.detalle, ' - ', NEW.detalle,
            "FECHA DE REGISTRO =", OLD.fecha_registro, ' - ', NEW.fecha_registro,
            "ESTATUS =", v_estatus_old, ' - ', v_estatus_new),
        DEFAULT,
        DEFAULT
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`daniela.aguilar`@`%`*/ /*!50003 TRIGGER `tbc_consumibles_BEFORE_DELETE` BEFORE DELETE ON `tbc_consumibles` FOR EACH ROW BEGIN
  DECLARE v_estatus VARCHAR(20) DEFAULT 'Activo';

    IF NOT OLD.estatus THEN
        SET v_estatus = "Inactivo";
    END IF;

    INSERT INTO tbi_bitacora VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Delete',
        'tbc_consumibles',
        CONCAT_WS(" ", "Se ha eliminado un consumible con los siguientes datos:",
            "NOMBRE =", OLD.nombre,
            "DESCRIPCION =", OLD.descripcion,
            "TIPO =", OLD.tipo,
            "DEPARTAMENTO =", OLD.departamento,
            "CANTIDAD EXISTENCIA =", OLD.cantidad_existencia,
            "DETALLE =", OLD.detalle,
            "FECHA DE REGISTRO =", OLD.fecha_registro,
            "ESTATUS =", v_estatus),
        DEFAULT,
        DEFAULT
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`daniela.aguilar`@`%`*/ /*!50003 TRIGGER `tbc_consumibles_AFTER_DELETE` AFTER DELETE ON `tbc_consumibles` FOR EACH ROW BEGIN


END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_departamentos`
--

DROP TABLE IF EXISTS `tbc_departamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_departamentos` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT COMMENT 'DESCRIPCION: Atributo clave primaria autoincremental que identificara cada registro del DEPARTAMENTO\nNATURALEZA: Cuantitativo\nTIPO: Numérico\nDOMINIO: Número Enteros Positivos\nCOMPOSICION:  1{0-9}*\n',
  `Nombre` varchar(100) NOT NULL COMMENT 'DESCRIPCION: Denominación del DEPARTAMENTO (Unidad de Negocio)\nNATURALEZA: Cualitativo\nTIPO: Alfanumerico\nDOMINIO: Letras y Numeros \nCOMPOSICION: 1{a-Z| |0-9}100',
  `AreaMedica_ID` int unsigned DEFAULT NULL,
  `Departamento_Superior_ID` int unsigned DEFAULT NULL,
  `Responsable_ID` int unsigned DEFAULT NULL,
  `Estatus` bit(1) NOT NULL DEFAULT b'1',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `fk_area_medica_1` (`AreaMedica_ID`),
  KEY `fk_departamento_1` (`Departamento_Superior_ID`),
  CONSTRAINT `fk_area_medica_1` FOREIGN KEY (`AreaMedica_ID`) REFERENCES `tbc_areas_medicas` (`ID`),
  CONSTRAINT `fk_departamento_1` FOREIGN KEY (`Departamento_Superior_ID`) REFERENCES `tbc_departamentos` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Tabla catalogo que almacenara la informacion de cada departamento del hospital, en base a su estructura organizacional.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_departamentos`
--

LOCK TABLES `tbc_departamentos` WRITE;
/*!40000 ALTER TABLE `tbc_departamentos` DISABLE KEYS */;
INSERT INTO `tbc_departamentos` VALUES (1,'Dirección General',NULL,NULL,NULL,_binary '','2024-01-24 00:15:10','2024-03-24 00:51:34'),(2,'Junta de Gobierno',NULL,1,NULL,_binary '','2024-01-24 00:15:12',NULL),(3,'Comités Hospitalarios',NULL,1,NULL,_binary '','2024-01-24 00:15:14',NULL),(4,'Comité de Transplante',NULL,1,NULL,_binary '','2024-01-24 00:15:14',NULL),(5,'Departamento de Calidad',NULL,1,NULL,_binary '','2024-01-24 00:15:14',NULL),(6,'Sub-Dirección Médica',NULL,1,NULL,_binary '','2024-01-24 00:15:14',NULL),(7,'Sub-Dirección Administrativa',NULL,1,NULL,_binary '','2024-01-24 00:15:14',NULL),(8,'Atención a Quejas',NULL,5,NULL,_binary '','2024-01-24 00:15:19',NULL),(9,'Seguridad del Paciente',NULL,5,NULL,_binary '','2024-01-24 00:15:19',NULL),(10,'Programación Quirúrgica',NULL,5,NULL,_binary '','2024-01-24 00:15:19',NULL),(11,'División de Medicina Interna',1,6,NULL,_binary '','2024-01-24 00:21:35',NULL),(12,'Terapia Intermedia',1,11,NULL,_binary '','2024-01-24 00:21:35',NULL),(13,'División de Pediatría',1,6,NULL,_binary '','2024-01-24 00:21:35',NULL),(14,'Servicio de Urgencias Pediátricas',1,13,NULL,_binary '','2024-01-24 00:21:35',NULL),(15,'Servicio de Traumatología',1,6,NULL,_binary '','2024-01-24 00:25:44',NULL),(16,'División de Cirugía',1,6,NULL,_binary '','2024-01-24 00:25:44',NULL),(17,'Servicio de Urgencias Adultos',1,6,NULL,_binary '','2024-01-24 00:25:44',NULL),(18,'Terapia Intensiva',1,6,NULL,_binary '','2024-01-24 00:25:44',NULL),(19,'Quirófano y Anestesiología',1,6,NULL,_binary '','2024-01-24 00:25:44',NULL),(20,'Centro de Mezclas',2,6,NULL,_binary '','2024-02-06 10:23:28',NULL),(21,'Radiología e Imagen',2,6,NULL,_binary '','2024-02-06 10:23:30',NULL),(22,'Genética',2,6,NULL,_binary '','2024-02-06 10:23:31',NULL),(23,'Laboratorio de Análisis Clínicos',2,6,NULL,_binary '','2024-02-06 10:23:32',NULL),(24,'Laboratorio de Histocompatibilidad',2,23,NULL,_binary '','2024-02-06 10:23:32',NULL),(25,'Hemodialisis',2,6,NULL,_binary '','2024-02-06 10:23:33',NULL),(26,'Laboratorio de Patología',2,6,NULL,_binary '','2024-02-06 20:23:00',NULL),(27,'Rehabilitación Pulmonar',2,6,NULL,_binary '','2024-02-06 20:23:00',NULL),(28,'Medicina Genómica',2,6,NULL,_binary '','2024-02-06 20:23:00',NULL),(29,'Banco de Sangre',2,6,NULL,_binary '','2024-02-06 20:23:00',NULL),(30,'Aféresis',2,29,NULL,_binary '','2024-02-06 20:23:00',NULL),(31,'Tele-Robótica',NULL,6,NULL,_binary '','2024-02-06 20:24:15',NULL),(32,'Jefatura de Enseñanza Médica',NULL,6,NULL,_binary '','2024-02-06 20:24:15',NULL),(33,'Ética e Investigación',NULL,6,NULL,_binary '','2024-02-06 20:24:15',NULL),(34,'Medicinal Legal',NULL,NULL,NULL,_binary '','2024-02-06 20:59:37',NULL),(35,'Violencia Intrafamiliar',3,34,NULL,_binary '','2024-02-06 20:59:37',NULL),(36,'Trabajo Social',3,6,NULL,_binary '','2024-02-06 20:59:37',NULL),(37,'Unidad de Vigilancia Epidemiológica Hospitalaria',3,6,NULL,_binary '','2024-02-06 20:59:37',NULL),(38,'Centro de Investigación de Estudios de la Salud',3,6,NULL,_binary '','2024-02-06 20:59:37',NULL),(39,'Comunicación Social',3,6,NULL,_binary '','2024-02-06 20:59:37',NULL),(40,'Consulta Externa',NULL,6,NULL,_binary '','2024-02-06 21:00:25',NULL),(41,'Terapia y Rehabilitación Física',NULL,40,NULL,_binary '','2024-02-06 21:00:25',NULL),(42,'Jefatura de Enfermería',4,6,NULL,_binary '','2024-02-06 21:55:48',NULL),(43,'Subjefatura de Enfermeras',4,42,NULL,_binary '','2024-02-06 21:55:48',NULL),(44,'Coordinación Enseñanza Enfermería',4,42,NULL,_binary '','2024-02-06 21:55:48',NULL),(45,'Supervisoras de Turno',4,43,NULL,_binary '','2024-02-06 21:55:48',NULL),(46,'Jefas de Servicio',4,45,NULL,_binary '','2024-02-06 21:55:48',NULL),(47,'Clínicas y Programas',4,45,NULL,_binary '','2024-02-06 21:55:48',NULL),(48,'Recursos Humanos',5,7,NULL,_binary '','2024-02-06 21:57:55',NULL),(49,'Archivo y Correspondencia',5,48,NULL,_binary '','2024-02-06 21:57:55',NULL),(50,'Dietética',5,7,NULL,_binary '','2024-02-06 21:57:55',NULL),(51,'Farmacia Intrahospitalaria',5,7,NULL,_binary '','2024-02-06 21:57:55',NULL),(52,'Coordinación de Asuntos Jurídicos y Administrativos',5,7,NULL,_binary '','2024-02-06 21:57:55',NULL),(53,'Vigilancia',5,52,NULL,_binary '','2024-02-06 21:57:55',NULL),(54,'Biomédica Conservación y Mantenimiento',5,7,NULL,_binary '','2024-02-06 22:04:44',NULL),(55,'Validación ',5,7,NULL,_binary '','2024-02-06 22:04:44',NULL),(56,'Recursos Materiales',5,7,NULL,_binary '','2024-02-06 22:04:44',NULL),(57,'Almacén',5,56,NULL,_binary '','2024-02-06 22:04:44',NULL),(58,'Insumos Especializados',5,56,NULL,_binary '','2024-02-06 22:04:44',NULL),(59,'Servicios Generales',5,7,NULL,_binary '','2024-02-06 22:04:44',NULL),(60,'Intendencia',5,59,NULL,_binary '','2024-02-06 22:04:44',NULL),(61,'Ropería',5,59,NULL,_binary '','2024-02-06 22:04:44',NULL),(62,'Recursos Financieros',5,7,NULL,_binary '','2024-02-13 10:38:19',NULL),(63,'Departamento Administrativo Hemodinamia',5,7,NULL,_binary '','2024-02-13 10:38:19',NULL),(64,'Relaciones Públicas',5,7,NULL,_binary '','2024-02-13 10:38:19',NULL),(65,'Nivel 7',5,64,NULL,_binary '\0','2024-02-13 10:38:19','2024-02-13 10:52:46'),(66,'Farmacia del Seguro Popular',5,7,NULL,_binary '','2024-02-13 10:38:19',NULL),(67,'Enlace Administrativo',5,7,NULL,_binary '','2024-02-13 10:38:19',NULL),(68,'Control de Gastos Catastróficos',5,67,NULL,_binary '','2024-02-13 10:38:19',NULL),(69,'Informática',5,7,NULL,_binary '','2024-02-13 10:38:19',NULL),(70,'Tecnología en la Salud',5,69,NULL,_binary '','2024-02-13 10:38:19',NULL),(71,'Registros Médicos',5,7,NULL,_binary '','2024-02-13 10:38:19',NULL);
/*!40000 ALTER TABLE `tbc_departamentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbc_espacios`
--

DROP TABLE IF EXISTS `tbc_espacios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_espacios` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Tipo` enum('Piso','Consultorio','Laboratorio','Quirófano','Sala de Espera','Edificio','Estacionamiento','Habitación','Cama','Sala Maternidad','Cunero','Morgue','Oficina','Sala de Juntas','Auditorio','Cafeteria','Capilla','Farmacia','Ventanilla','Recepción') NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Departamento_ID` int unsigned NOT NULL,
  `Estatus` enum('Activo','Inactivo','En remodelación','Clausurado','Reubicado','Temporal') NOT NULL DEFAULT 'Activo',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  `Capacidad` int NOT NULL DEFAULT '0',
  `Espacio_Superior_ID` int unsigned DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Nombre_UNIQUE` (`Nombre`),
  KEY `fk_departamentos_3_idx` (`Departamento_ID`),
  KEY `fk_espacios_1_idx` (`Espacio_Superior_ID`),
  CONSTRAINT `fk_departamentos_3` FOREIGN KEY (`Departamento_ID`) REFERENCES `tbc_departamentos` (`ID`),
  CONSTRAINT `fk_espacios_1` FOREIGN KEY (`Espacio_Superior_ID`) REFERENCES `tbc_espacios` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_espacios`
--

LOCK TABLES `tbc_espacios` WRITE;
/*!40000 ALTER TABLE `tbc_espacios` DISABLE KEYS */;
INSERT INTO `tbc_espacios` VALUES (1,'Edificio','Medicina General',1,'Activo','2024-07-18 11:15:08',NULL,0,NULL),(2,'Piso','Planta Baja',56,'Activo','2024-07-18 11:15:08',NULL,0,1),(3,'Consultorio','A-101',11,'Activo','2024-07-18 11:15:08',NULL,0,2),(4,'Consultorio','A-102',11,'Activo','2024-07-18 11:15:08',NULL,0,2),(5,'Consultorio','A-103',11,'Activo','2024-07-18 11:15:08',NULL,0,2),(6,'Consultorio','A-104',17,'Activo','2024-07-18 11:15:08',NULL,0,2),(7,'Consultorio','A-105',17,'En remodelación','2024-07-18 11:15:08','2024-07-18 11:15:08',0,2),(8,'Quirófano','A-106',16,'Activo','2024-07-18 11:15:08',NULL,0,2),(9,'Quirófano','A-107',16,'Activo','2024-07-18 11:15:08',NULL,0,2),(10,'Sala de Espera','A-108',16,'Activo','2024-07-18 11:15:08',NULL,0,2),(11,'Sala de Espera','A-109',16,'Activo','2024-07-18 11:15:08','2024-07-18 11:15:08',80,2),(12,'Piso','Planta Alta',56,'Activo','2024-07-18 11:15:08',NULL,0,1),(13,'Habitación','A-201',11,'Activo','2024-07-18 11:15:08',NULL,0,12),(14,'Habitación','A-202',11,'Activo','2024-07-18 11:15:08',NULL,0,12),(15,'Habitación','A-203',11,'Activo','2024-07-18 11:15:08',NULL,0,12),(16,'Habitación','A-204',11,'Activo','2024-07-18 11:15:08',NULL,0,12),(17,'Habitación','A-205',11,'Activo','2024-07-18 11:15:08',NULL,0,12),(18,'Laboratorio','A206',23,'Activo','2024-07-18 11:15:08',NULL,0,12),(20,'Recepción','A-208',1,'Activo','2024-07-18 11:15:08',NULL,0,12);
/*!40000 ALTER TABLE `tbc_espacios` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`bruno.lemus`@`%`*/ /*!50003 TRIGGER `tbc_espacios_AFTER_INSERT` AFTER INSERT ON `tbc_espacios` FOR EACH ROW BEGIN
    DECLARE v_estatus VARCHAR(20);
    DECLARE departamento_nombre VARCHAR(255);
    DECLARE espacio_superior_nombre VARCHAR(255);

   SET v_estatus = CASE 
                        WHEN NEW.Estatus = 'Activo' THEN 'Activo'
                        WHEN NEW.Estatus = 'Inactivo' THEN 'Inactivo'
                        WHEN NEW.Estatus = 'En remodelación' THEN 'En remodelación'
                        WHEN NEW.Estatus = 'Clausurado' THEN 'Clausurado'
                        WHEN NEW.Estatus = 'Reubicado' THEN 'Reubicado'
                        WHEN NEW.Estatus = 'Temporal' THEN 'Temporal'
                        ELSE 'Desconocido'
                    END;

    -- Obtener el nombre del departamento
    SET departamento_nombre = (SELECT Nombre FROM tbc_departamentos WHERE ID = NEW.Departamento_ID);
    
    -- Obtener el nombre del espacio superior
    SET espacio_superior_nombre = (SELECT Nombre FROM tbc_espacios WHERE ID = NEW.Espacio_superior_ID);

    -- Registrar la inserción del nuevo espacio en la bitácora
    INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro) 
    VALUES (
        CURRENT_USER(), 
        'Create', 
        'tbc_espacios', 
        CONCAT_WS('\n',
            CONCAT('Se ha agregado un nuevo ESPACIO con el Nombre: ', NEW.Nombre),
            CONCAT('Tipo: ', NEW.Tipo),
            CONCAT('Departamento: ', IFNULL(departamento_nombre, 'Desconocido')),
            CONCAT('Estatus: ', v_estatus),
            CONCAT('Fecha de Registro: ', NEW.Fecha_Registro),
            CONCAT('Fecha de Actualización: ', IFNULL(NEW.Fecha_Actualizacion, 'NULL')),
            CONCAT('Capacidad: ', NEW.Capacidad),
            CONCAT('Espacio Superior: ', IFNULL(espacio_superior_nombre, 'Ninguno'))
        ),
        b'1', -- Estatus activo
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`bruno.lemus`@`%`*/ /*!50003 TRIGGER `tbb_personas_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_espacios` FOR EACH ROW BEGIN
	set new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`bruno.lemus`@`%`*/ /*!50003 TRIGGER `tbc_espacios_AFTER_UPDATE` AFTER UPDATE ON `tbc_espacios` FOR EACH ROW BEGIN
    DECLARE v_estatus VARCHAR(20);
    DECLARE departamento_nombre VARCHAR(255);
    DECLARE espacio_superior_nombre VARCHAR(255);

    -- Asignar el valor de estatus
    SET v_estatus = CASE 
                        WHEN NEW.Estatus = 'Activo' THEN 'Activo'
                        WHEN NEW.Estatus = 'Inactivo' THEN 'Inactivo'
                        WHEN NEW.Estatus = 'En remodelación' THEN 'En remodelación'
                        WHEN NEW.Estatus = 'Clausurado' THEN 'Clausurado'
                        WHEN NEW.Estatus = 'Reubicado' THEN 'Reubicado'
                        WHEN NEW.Estatus = 'Temporal' THEN 'Temporal'
                        ELSE 'Desconocido'
                    END;

    -- Obtener el nombre del departamento
    SET departamento_nombre = (SELECT Nombre FROM tbc_departamentos WHERE ID = NEW.Departamento_ID);
    
    -- Obtener el nombre del espacio superior
    SET espacio_superior_nombre = (SELECT Nombre FROM tbc_espacios WHERE ID = NEW.Espacio_superior_ID);

    -- Registrar la actualización del espacio en la bitácora
    INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro) 
    VALUES (
        CURRENT_USER(), 
        'Update', 
        'tbc_espacios', 
        CONCAT_WS('\n',
            CONCAT('Se ha actualizado un ESPACIO con el Nombre: ', NEW.Nombre),
            CONCAT('Tipo: ', NEW.Tipo),
            CONCAT('Departamento: ', IFNULL(departamento_nombre, 'Desconocido')),
            CONCAT('Estatus: ', v_estatus),
            CONCAT('Fecha de Registro: ', NEW.Fecha_Registro),
            CONCAT('Fecha de Actualización: ', IFNULL(NEW.Fecha_Actualizacion, 'NULL')),
            CONCAT('Capacidad: ', NEW.Capacidad),
            CONCAT('Espacio Superior: ', IFNULL(espacio_superior_nombre, 'Ninguno'))
        ),
        b'1', -- Estatus activo
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`bruno.lemus`@`%`*/ /*!50003 TRIGGER `tbc_espacios_AFTER_DELETE` AFTER DELETE ON `tbc_espacios` FOR EACH ROW BEGIN
    DECLARE v_estatus VARCHAR(20);
    DECLARE departamento_nombre VARCHAR(255);
    DECLARE espacio_superior_nombre VARCHAR(255);

    -- Asignar el valor de estatus
    SET v_estatus = CASE 
                        WHEN OLD.Estatus = 'Activo' THEN 'Activo'
                        WHEN OLD.Estatus = 'Inactivo' THEN 'Inactivo'
                        WHEN OLD.Estatus = 'En remodelación' THEN 'En remodelación'
                        WHEN OLD.Estatus = 'Clausurado' THEN 'Clausurado'
                        WHEN OLD.Estatus = 'Reubicado' THEN 'Reubicado'
                        WHEN OLD.Estatus = 'Temporal' THEN 'Temporal'
                        ELSE 'Desconocido'
                    END;

    -- Obtener el nombre del departamento
    SET departamento_nombre = (SELECT Nombre FROM tbc_departamentos WHERE ID = OLD.Departamento_ID);
    
    -- Obtener el nombre del espacio superior
    SET espacio_superior_nombre = (SELECT Nombre FROM tbc_espacios WHERE ID = OLD.Espacio_superior_ID);

    -- Registrar la eliminación del espacio en la bitácora
    INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro) 
    VALUES (
        CURRENT_USER(), 
        'Delete', 
        'tbc_espacios', 
        CONCAT_WS('\n',
            CONCAT('Se ha eliminado un ESPACIO con el Nombre: ', OLD.Nombre),
            CONCAT('Tipo: ', OLD.Tipo),
            CONCAT('Departamento: ', IFNULL(departamento_nombre, 'Desconocido')),
            CONCAT('Estatus: ', v_estatus),
            CONCAT('Fecha de Registro: ', OLD.Fecha_Registro),
            CONCAT('Fecha de Actualización: ', IFNULL(OLD.Fecha_Actualizacion, 'NULL')),
            CONCAT('Capacidad: ', OLD.Capacidad),
            CONCAT('Espacio Superior: ', IFNULL(espacio_superior_nombre, 'Ninguno'))
        ),
        b'1', -- Estatus activo
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_estudios`
--

DROP TABLE IF EXISTS `tbc_estudios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_estudios` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Tipo` varchar(50) NOT NULL,
  `Nivel_Urgencia` varchar(50) NOT NULL,
  `SolicitudID` int unsigned NOT NULL,
  `ConsumiblesID` int DEFAULT NULL,
  `Estatus` varchar(50) NOT NULL,
  `Total_Costo` decimal(10,2) NOT NULL,
  `Dirigido_A` varchar(100) DEFAULT NULL,
  `Observaciones` text,
  `Fecha_Registro` datetime NOT NULL,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  `ConsumibleID` int DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_estudios`
--

LOCK TABLES `tbc_estudios` WRITE;
/*!40000 ALTER TABLE `tbc_estudios` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbc_estudios` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Juan.cruz`@`%`*/ /*!50003 TRIGGER `tbc_estudios_AFTER_INSERT` AFTER INSERT ON `tbc_estudios` FOR EACH ROW BEGIN
	INSERT INTO tbi_bitacora VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Create',
        'tbb_estudios',
        CONCAT_WS(' ', 
            'Se ha creado un nuevo estudio médico con los siguientes datos:\n',
            'ID: ', NEW.ID, '\n',
            'Tipo: ', NEW.Tipo, '\n',
            'Estatus: ', NEW.Estatus, '\n',
            'Total Costo: ', NEW.Total_Costo, '\n',
            'Dirigido A: ', NEW.Dirigido_A, '\n',
            'Observaciones: ', NEW.Observaciones, '\n',
            'Nivel Urgencia: ', NEW.Nivel_Urgencia, '\n',
            'Fecha Registro: ', NEW.Fecha_Registro, '\n'),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Juan.cruz`@`%`*/ /*!50003 TRIGGER `tbb_estudios_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_estudios` FOR EACH ROW BEGIN
	set new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Juan.cruz`@`%`*/ /*!50003 TRIGGER `tbc_estudios_AFTER_UPDATE` AFTER UPDATE ON `tbc_estudios` FOR EACH ROW BEGIN
	INSERT INTO tbi_bitacora VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Update',
        'tbb_estudios',
        CONCAT_WS('',
            'Se ha actualizado un estudio médico con los siguientes datos:\n',
            'ID: ', NEW.ID, '\n',
            'Tipo: ', NEW.Tipo, '\n',
            'Estatus: ', NEW.Estatus, '\n',
            'Total Costo: ', NEW.Total_Costo, '\n',
            'Dirigido A: ', NEW.Dirigido_A, '\n',
            'Observaciones: ', NEW.Observaciones, '\n',
            'Nivel Urgencia: ', NEW.Nivel_Urgencia, '\n',
            'Fecha Registro: ', NEW.Fecha_Registro, '\n',
            'Fecha Actualización: ', NEW.Fecha_Actualizacion, '\n'
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Juan.cruz`@`%`*/ /*!50003 TRIGGER `tbc_estudios_AFTER_DELETE` AFTER DELETE ON `tbc_estudios` FOR EACH ROW BEGIN
	INSERT INTO tbi_bitacora (
        ID,
        Usuario,
        Operacion,
        Tabla,
        Descripcion,
        Estatus,
        Fecha_Registro
    ) VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Delete',
        'tbb_estudios',
        CONCAT_WS('',
            'Se ha eliminado un estudio médico con los siguientes datos:\n',
            'ID: ', OLD.ID, '\n',
            'Tipo: ', OLD.Tipo, '\n',
            'Estatus: ', OLD.Estatus, '\n',
            'Total Costo: ', OLD.Total_Costo, '\n',
            'Dirigido A: ', OLD.Dirigido_A, '\n',
            'Observaciones: ', OLD.Observaciones, '\n',
            'Nivel Urgencia: ', OLD.Nivel_Urgencia, '\n',
            'Fecha Registro: ', OLD.Fecha_Registro, '\n'
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_medicamentos`
--

DROP TABLE IF EXISTS `tbc_medicamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_medicamentos` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Nombre_comercial` varchar(80) NOT NULL,
  `Nombre_generico` varchar(80) NOT NULL,
  `Via_administracion` enum('Oral','Intravenoso','Rectal','Cutaneo','Subcutaneo','Oftalmica','Otica','Nasal','Topica','Parental') NOT NULL,
  `Presentacion` enum('Comprimidos','Grageas','Capsulas','Jarabes','Gotas','Solucion','Pomada','Jabon','Supositorios','Viales') NOT NULL,
  `Tipo` enum('Analgesicos','Antibioticos','Antidepresivos','Antihistaminicos','Antiinflamatorios','Antipsicoticos') NOT NULL,
  `Cantidad` int unsigned NOT NULL,
  `Volumen` decimal(10,2) NOT NULL,
  `Fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_medicamentos`
--

LOCK TABLES `tbc_medicamentos` WRITE;
/*!40000 ALTER TABLE `tbc_medicamentos` DISABLE KEYS */;
INSERT INTO `tbc_medicamentos` VALUES (1,'Tylenol','Paracetamol','Oral','Comprimidos','Analgesicos',120,10.00,'2024-08-22 10:28:39','2024-08-22 10:28:39'),(3,'Zoloft','Sertralina','Oral','Comprimidos','Antidepresivos',200,0.00,'2024-08-22 10:28:39',NULL),(4,'Claritin','Loratadina','Oral','Grageas','Antihistaminicos',150,0.00,'2024-08-22 10:28:39',NULL),(5,'Advil','Ibuprofeno','Oral','Comprimidos','Antiinflamatorios',300,0.00,'2024-08-22 10:28:39',NULL);
/*!40000 ALTER TABLE `tbc_medicamentos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Cristian.Ojeda`@`%`*/ /*!50003 TRIGGER `tbc_medicamentos_AFTER_INSERT` AFTER INSERT ON `tbc_medicamentos` FOR EACH ROW BEGIN
 INSERT INTO tbi_bitacora VALUES(
        DEFAULT,
        CURRENT_USER(),
        'Create',
        'tbc_medicamentos',
        CONCAT_WS(' ', 
            'Se ha insertado un nuevo medicamento con ID:', NEW.ID,
            '\n Nombre Comercial:', NEW.Nombre_comercial,
            '\n Nombre Genérico:', NEW.Nombre_generico,
            '\n Vía de Administración:', NEW.Via_administracion,
            '\n Presentación:', NEW.Presentacion,
            '\n Tipo:', NEW.Tipo,
            '\n Cantidad:', NEW.Cantidad,
            '\n Volumen:', NEW.Volumen
        ),
        DEFAULT,
        DEFAULT
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Cristian.Ojeda`@`%`*/ /*!50003 TRIGGER `tbc_medicamentos_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_medicamentos` FOR EACH ROW BEGIN
	set new.Fecha_Actualizacion = current_time();

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Cristian.Ojeda`@`%`*/ /*!50003 TRIGGER `tbc_medicamentos_AFTER_UPDATE` AFTER UPDATE ON `tbc_medicamentos` FOR EACH ROW BEGIN
   INSERT INTO tbi_bitacora VALUES(
        DEFAULT,
        CURRENT_USER(),
        'Update',
        'tbc_medicamentos',
        CONCAT_WS(' ', 
            'Se ha actualizado el medicamento con ID:', OLD.ID,
            '\n Nombre Comercial:', OLD.Nombre_comercial, '-', NEW.Nombre_comercial,
            '\n Nombre Genérico:', OLD.Nombre_generico, '-', NEW.Nombre_generico,
            '\n Vía de Administración:', OLD.Via_administracion, '-', NEW.Via_administracion,
            '\n Presentación:', OLD.Presentacion, '-', NEW.Presentacion,
            '\n Tipo:', OLD.Tipo, '-', NEW.Tipo,
            '\n Cantidad:', OLD.Cantidad, '-', NEW.Cantidad,
            '\n Volumen:', OLD.Volumen, '-', NEW.Volumen
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Cristian.Ojeda`@`%`*/ /*!50003 TRIGGER `tbc_medicamentos_AFTER_DELETE` AFTER DELETE ON `tbc_medicamentos` FOR EACH ROW BEGIN
  INSERT INTO tbi_bitacora VALUES(
        DEFAULT,
        CURRENT_USER(),
        'Delete',
        'tbc_medicamentos',
        CONCAT_WS(' ', 
            'Se ha eliminado el medicamento con ID:', OLD.ID,
            '\n Nombre Comercial:', OLD.Nombre_comercial,
            '\n Nombre Genérico:', OLD.Nombre_generico
        ),
        DEFAULT,
        DEFAULT
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_organos`
--

DROP TABLE IF EXISTS `tbc_organos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_organos` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(45) NOT NULL,
  `Aparato_Sistema` varchar(50) NOT NULL,
  `Descripcion` text NOT NULL,
  `Detalle_Organo_ID` int unsigned NOT NULL,
  `Disponibilidad` varchar(45) NOT NULL,
  `Tipo` varchar(45) NOT NULL,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  `Fecha_Registro` datetime DEFAULT NULL,
  `Estatus` bit(1) DEFAULT b'1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Detalle_Organo_ID_UNIQUE` (`Detalle_Organo_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_organos`
--

LOCK TABLES `tbc_organos` WRITE;
/*!40000 ALTER TABLE `tbc_organos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbc_organos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Alyn.Fosado`@`%`*/ /*!50003 TRIGGER `tbc_organos_AFTER_INSERT` AFTER INSERT ON `tbc_organos` FOR EACH ROW BEGIN
DECLARE v_estatus VARCHAR(20) DEFAULT 'Activo';

    -- Validamos el estatus para asignarle su valor textual 
    IF NOT NEW.Estatus THEN 
        SET v_estatus = "Inactivo";
    END IF;

    INSERT INTO tbi_bitacora (ID, Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro) 
    VALUES (DEFAULT, CURRENT_USER(), 'Create','tbc_organos', CONCAT_WS(' ', 'Se ha registrado un nuevo órgano con los siguientes datos: ', 
                         ' Nombre: ', NEW.Nombre, 
                         ', Aparato Sistema: ', NEW.Aparato_Sistema, 
                         ', Descripcion: ', NEW.Descripcion, 
                         ', Disponibilidad: ', NEW.Disponibilidad, 
                         ', Tipo: ', NEW.Tipo, 
                         ', Estatus: ', v_estatus),
        DEFAULT, 
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Alyn.Fosado`@`%`*/ /*!50003 TRIGGER `tbc_organos_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_organos` FOR EACH ROW BEGIN
 SET NEW.Fecha_Actualizacion = CURRENT_TIMESTAMP();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Alyn.Fosado`@`%`*/ /*!50003 TRIGGER `tbc_organos_AFTER_UPDATE` AFTER UPDATE ON `tbc_organos` FOR EACH ROW BEGIN
 DECLARE v_estatus_old VARCHAR(20) DEFAULT 'Activo';
    DECLARE v_estatus_new VARCHAR(20) DEFAULT 'Activo';

    -- Validamos el estatus antiguo y nuevo para asignar sus valores textuales 
    IF NOT OLD.Estatus THEN 
        SET v_estatus_old = "Inactivo";
    END IF;

    IF NOT NEW.Estatus THEN 
        SET v_estatus_new = "Inactivo";
    END IF;

    INSERT INTO tbi_bitacora ( ID, Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro) 
    VALUES (DEFAULT, CURRENT_USER(),'Update','tbc_organos', CONCAT_WS(' ', 'Se ha actualizado un órgano con los siguientes datos:', 
                         ' Nombre Antiguo: ', OLD.Nombre, ', Nombre Nuevo: ', NEW.Nombre, 
                         ', Aparato Sistema Antiguo: ', OLD.Aparato_Sistema, ', Aparato Sistema Nuevo: ', NEW.Aparato_Sistema, 
                         ', Descripcion Antiguo: ', OLD.Descripcion, ', Descripcion Nuevo: ', NEW.Descripcion, 
                         ', Disponibilidad Antiguo: ', OLD.Disponibilidad, ', Disponibilidad Nuevo: ', NEW.Disponibilidad, 
                         ', Tipo Antiguo: ', OLD.Tipo, ', Tipo Nuevo: ', NEW.Tipo, 
                         ', Estatus Antiguo: ', v_estatus_old, ', Estatus Nuevo: ', v_estatus_new),
        DEFAULT, 
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Alyn.Fosado`@`%`*/ /*!50003 TRIGGER `tbc_organos_AFTER_DELETE` AFTER DELETE ON `tbc_organos` FOR EACH ROW BEGIN
DECLARE v_estatus VARCHAR(20) DEFAULT 'Activo';

    -- Validamos el estatus para asignarle su valor textual 
    IF NOT OLD.Estatus THEN 
        SET v_estatus = "Inactivo";
    END IF;

    INSERT INTO tbi_bitacora ( ID,  Usuario,   Operacion,   Tabla,   Descripcion,   Estatus,  Fecha_Registro ) VALUES ( DEFAULT,  CURRENT_USER(),
        'Delete',
        'tbc_organos',
        CONCAT_WS(' ', 'Se ha eliminado un órgano con los siguientes datos:', 
                         ' Nombre: ', OLD.Nombre, 
                         ', Aparato Sistema: ', OLD.Aparato_Sistema, 
                         ', Descripcion: ', OLD.Descripcion, 
                         ', Disponibilidad: ', OLD.Disponibilidad, 
                         ', Tipo: ', OLD.Tipo, 
                         ', Estatus: ', v_estatus),
        DEFAULT, 
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_puestos`
--

DROP TABLE IF EXISTS `tbc_puestos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_puestos` (
  `PuestoID` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `Salario` decimal(10,2) DEFAULT NULL,
  `Turno` enum('Mañana','Tarde','Noche') DEFAULT NULL,
  `Creado` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `Modificado` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`PuestoID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_puestos`
--

LOCK TABLES `tbc_puestos` WRITE;
/*!40000 ALTER TABLE `tbc_puestos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbc_puestos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`jesus.rios`@`%`*/ /*!50003 TRIGGER `tbc_puestos_AFTER_INSERT` AFTER INSERT ON `tbc_puestos` FOR EACH ROW BEGIN
    INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro)
    VALUES (CURRENT_USER(), 'Create', 'tbc_puestos', 
            CONCAT('Se insertó un nuevo puesto: ', NEW.Nombre, ' (ID: ', NEW.PuestoID, '), Descripción: ', NEW.Descripcion, ', Salario: ', NEW.Salario, ', Turno: ', NEW.Turno), 
            b'1', NOW());
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`jesus.rios`@`%`*/ /*!50003 TRIGGER `tbc_puestos_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_puestos` FOR EACH ROW BEGIN
    INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro)
    VALUES (CURRENT_USER(), 'Update', 'tbc_puestos', 
            CONCAT('Se actualizará el puesto: ', OLD.Nombre, ' (ID: ', OLD.PuestoID, '), Descripción: ', OLD.Descripcion, ', Salario: ', OLD.Salario, ', Turno: ', OLD.Turno), 
            b'1', NOW());
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`jesus.rios`@`%`*/ /*!50003 TRIGGER `tbc_puestos_AFTER_UPDATE` AFTER UPDATE ON `tbc_puestos` FOR EACH ROW BEGIN
    INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro)
    VALUES (CURRENT_USER(), 'Update', 'tbc_puestos', 
            CONCAT('Se actualizó el puesto: ', NEW.Nombre, ' (ID: ', NEW.PuestoID, '), Descripción: ', NEW.Descripcion, ', Salario: ', NEW.Salario, ', Turno: ', NEW.Turno), 
            b'1', NOW());
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`jesus.rios`@`%`*/ /*!50003 TRIGGER `tbc_puestos_AFTER_DELETE` AFTER DELETE ON `tbc_puestos` FOR EACH ROW BEGIN
    INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro)
    VALUES (CURRENT_USER(), 'Delete', 'tbc_puestos', 
            CONCAT('Se eliminó el puesto: ', OLD.Nombre, ' (ID: ', OLD.PuestoID, '), Descripción: ', OLD.Descripcion, ', Salario: ', OLD.Salario, ', Turno: ', OLD.Turno), 
            b'1', NOW());
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_roles`
--

DROP TABLE IF EXISTS `tbc_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_roles` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(50) NOT NULL,
  `Descripcion` text,
  `Estatus` bit(1) DEFAULT b'1',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_roles`
--

LOCK TABLES `tbc_roles` WRITE;
/*!40000 ALTER TABLE `tbc_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbc_roles` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_roles_AFTER_INSERT` AFTER INSERT ON `tbc_roles` FOR EACH ROW BEGIN
DECLARE v_estatus VARCHAR(20) DEFAULT 'Activo';
    
    -- Validamos el estatus del registro y le asignamos una etiqueta para la descripción
    IF NOT new.Estatus THEN
     SET v_estatus = "Inactivo";
	END IF;
    
    INSERT INTO tbi_bitacora VALUES(
		default, 
        current_user(), 
        'Create', 
        'tbc_roles', 
        CONCAT_WS(' ','Se ha agregado un nuevo rol de usuario con los siguientes datos:',
        'NOMBRE:',new.nombre, 'DESCRIPCION:', new.descripcion, 'ESTATUS:', v_estatus),
        DEFAULT, 
        DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_roles_usuarios_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_roles` FOR EACH ROW BEGIN
   SET new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_roles_usuarios_AFTER_UPDATE` AFTER UPDATE ON `tbc_roles` FOR EACH ROW BEGIN
	DECLARE v_estatus_old VARCHAR(20) DEFAULT 'Activo';
    DECLARE v_estatus_new VARCHAR(20) DEFAULT 'Activo';
    
    -- Validamos el estatus del registro y le asignamos una etiqueta para la descripción
    IF NOT new.Estatus THEN
     SET v_estatus_new = "Inactivo";
	END IF;
    
    IF NOT old.Estatus THEN
     SET v_estatus_old = "Inactivo";
	END IF;
    
    INSERT INTO tbi_bitacora VALUES(
		default, 
        current_user(), 
        'Update', 
        'tbc_roles', 
        CONCAT_WS(' ','Se ha modificado un rol de usuario existente con los siguientes datos:',
        'NOMBRE:',old.nombre,' - ', new.nombre, 
        'DESCRIPCION:', old.descripcion, ' - ', new.descripcion, 
        'ESTATUS:', v_estatus_old, ' - ', v_estatus_new),
        DEFAULT, 
        DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_roles_usuarios_AFTER_DELETE` AFTER DELETE ON `tbc_roles` FOR EACH ROW BEGIN
DECLARE v_estatus VARCHAR(20) DEFAULT 'Activo';
    
    -- Validamos el estatus del registro y le asignamos una etiqueta para la descripción
    IF NOT old.Estatus THEN
     SET v_estatus = "Inactivo";
	END IF;
    
    INSERT INTO tbi_bitacora VALUES(
		default, 
        current_user(), 
        'Delete', 
        'tbc_roles', 
        CONCAT_WS(' ','Se ha eliminado un rol de usuario existente con los siguientes datos:',
        'NOMBRE:',old.nombre, 'DESCRIPCION:', old.descripcion, 'ESTATUS:', v_estatus),
        DEFAULT, 
        DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_servicios_medicos`
--

DROP TABLE IF EXISTS `tbc_servicios_medicos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_servicios_medicos` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(255) NOT NULL,
  `Descripcion` text,
  `Observaciones` text,
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Nombre_UNIQUE` (`Nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_servicios_medicos`
--

LOCK TABLES `tbc_servicios_medicos` WRITE;
/*!40000 ALTER TABLE `tbc_servicios_medicos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbc_servicios_medicos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`alexis.gomez`@`%`*/ /*!50003 TRIGGER `tbc_servicios_medicos_AFTER_INSERT` AFTER INSERT ON `tbc_servicios_medicos` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora
    VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Create',
        'tbc_servicios_medicos',
        CONCAT_WS(' ',
            'Se ha registrado un nuevo servicio médico con los siguientes datos:','\n',
            'NOMBRE:', NEW.nombre,'\n',
            'DESCRIPCION:', NEW.descripcion,'\n',
            'OBSERVACIONES:', NEW.observaciones,'\n',
            'FECHA REGISTRO:', NEW.fecha_registro,'\n',
            'FECHA ACTUALIZACION:', NEW.fecha_actualizacion,'\n'
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`alexis.gomez`@`%`*/ /*!50003 TRIGGER `tbc_servicios_medicos_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_servicios_medicos` FOR EACH ROW BEGIN
set new.fecha_actualizacion = current_timestamp();

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`alexis.gomez`@`%`*/ /*!50003 TRIGGER `tbc_servicios_medicos_AFTER_UPDATE` AFTER UPDATE ON `tbc_servicios_medicos` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora 
    VALUES (
        DEFAULT, 
        CURRENT_USER(), 
        'Update', 
        'tbc_servicios_medicos', 
        CONCAT_WS(' ', 
            'Se ha modificado un servicio médico con los siguientes datos:', '\n',
            'NOMBRE:', OLD.nombre, '-', NEW.nombre, '\n',
            'DESCRIPCION:', OLD.descripcion, '-', NEW.descripcion, '\n',
            'OBSERVACIONES:', OLD.observaciones, '-', NEW.observaciones, '\n',
            'FECHA REGISTRO:', OLD.fecha_registro, '-', NEW.fecha_registro, '\n',
            'FECHA ACTUALIZACION:', OLD.fecha_actualizacion, '-', NEW.fecha_actualizacion, '\n'
        ), 
        DEFAULT, 
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`alexis.gomez`@`%`*/ /*!50003 TRIGGER `tbc_servicios_medicos_AFTER_DELETE` AFTER DELETE ON `tbc_servicios_medicos` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora
    VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Delete',
        'tbc_servicios_medicos',
        CONCAT_WS(' ',
            'Se ha eliminado un servicio médico con los siguientes datos:','\n',
            'NOMBRE:', OLD.nombre,'\n',
            'DESCRIPCION:', OLD.descripcion,'\n',
            'OBSERVACIONES:', OLD.observaciones,'\n',
            'FECHA REGISTRO:', OLD.fecha_registro,'\n',
            'FECHA ACTUALIZACION:', OLD.fecha_actualizacion,'\n'
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_departamentos_servicios`
--

DROP TABLE IF EXISTS `tbd_departamentos_servicios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_departamentos_servicios` (
  `Departamento_ID` int unsigned NOT NULL,
  `Servicio_ID` int unsigned NOT NULL,
  `Requisitos` text,
  `Restricciones` text,
  `Estatus` bit(1) NOT NULL DEFAULT b'1',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`Departamento_ID`,`Servicio_ID`),
  KEY `fk_servicios_medicos_1_idx` (`Servicio_ID`),
  CONSTRAINT `fk_departamentos_1` FOREIGN KEY (`Departamento_ID`) REFERENCES `tbc_departamentos` (`ID`),
  CONSTRAINT `fk_servicios_medicos_1` FOREIGN KEY (`Servicio_ID`) REFERENCES `tbc_servicios_medicos` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_departamentos_servicios`
--

LOCK TABLES `tbd_departamentos_servicios` WRITE;
/*!40000 ALTER TABLE `tbd_departamentos_servicios` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_departamentos_servicios` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`alexis.gomez`@`%`*/ /*!50003 TRIGGER `tbd_departamentos_servicios_AFTER_INSERT` AFTER INSERT ON `tbd_departamentos_servicios` FOR EACH ROW BEGIN
DECLARE v_departamento_nombre VARCHAR(100);
    DECLARE v_servicio_nombre VARCHAR(100);
    
    -- Obtener el nombre del departamento
    SELECT nombre INTO v_departamento_nombre
    FROM tbc_departamentos
    WHERE id = NEW.Departamento_ID;
    
    -- Obtener el nombre del servicio médico
    SELECT nombre INTO v_servicio_nombre
    FROM tbc_servicios_medicos
    WHERE id = NEW.Servicio_ID;
    
    INSERT INTO tbi_bitacora
    VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Create',
        'tbd_departamentos_servicios',
        CONCAT_WS(' ',
            'Se ha registrado un nuevo departamento-servicio con los siguientes datos:', '\n',
            'Departamento:', v_departamento_nombre, '\n',
            'Servicio Médico:', v_servicio_nombre, '\n',
            'Requisitos:', NEW.Requisitos, '\n',
            'Restricciones:', NEW.Restricciones, '\n',
            'Estatus:', 'Activo', '\n',  -- Modificado a "activo"
            'Fecha_Registro:', NEW.Fecha_Registro, '\n',
            'Fecha_Actualizacion:', NEW.Fecha_Actualizacion, '\n'
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`alexis.gomez`@`%`*/ /*!50003 TRIGGER `tbd_departamentos_servicios_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_departamentos_servicios` FOR EACH ROW BEGIN
set new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`alexis.gomez`@`%`*/ /*!50003 TRIGGER `tbd_departamentos_servicios_AFTER_UPDATE` AFTER UPDATE ON `tbd_departamentos_servicios` FOR EACH ROW BEGIN
  DECLARE v_old_departamento_nombre VARCHAR(100);
    DECLARE v_old_servicio_nombre VARCHAR(100);
    DECLARE v_new_departamento_nombre VARCHAR(100);
    DECLARE v_new_servicio_nombre VARCHAR(100);
    
    -- Obtener el nombre del departamento antes del cambio
    SELECT nombre INTO v_old_departamento_nombre
    FROM tbc_departamentos
    WHERE id = OLD.Departamento_ID;
    
    -- Obtener el nombre del servicio médico antes del cambio
    SELECT nombre INTO v_old_servicio_nombre
    FROM tbc_servicios_medicos
    WHERE id = OLD.Servicio_ID;
    
    -- Obtener el nombre del departamento después del cambio
    SELECT nombre INTO v_new_departamento_nombre
    FROM tbc_departamentos
    WHERE id = NEW.Departamento_ID;
    
    -- Obtener el nombre del servicio médico después del cambio
    SELECT nombre INTO v_new_servicio_nombre
    FROM tbc_servicios_medicos
    WHERE id = NEW.Servicio_ID;
    
    INSERT INTO tbi_bitacora 
    VALUES (
        DEFAULT, 
        CURRENT_USER(), 
        'Update', 
        'tbd_departamentos_servicios', 
        CONCAT_WS(' ', 
            'Se ha modificado un departamento-servicio con los siguientes datos:', '\n',
            'Departamento (antes):', v_old_departamento_nombre, ' -> ', v_new_departamento_nombre, '\n',
            'Servicio Médico (antes):', v_old_servicio_nombre, ' -> ', v_new_servicio_nombre, '\n',
            'Requisitos (antes):', OLD.Requisitos, ' -> ', NEW.Requisitos, '\n',
            'Restricciones (antes):', OLD.Restricciones, ' -> ', NEW.Restricciones, '\n',
            'Estatus (antes):','activo', ' -> ', 'activo', '\n',  -- Modificado a "activo"
            'Fecha_Registro (antes):', OLD.Fecha_Registro, ' -> ', NEW.Fecha_Registro, '\n',
            'Fecha_Actualizacion:', OLD.Fecha_Actualizacion, ' -> ', NEW.Fecha_Actualizacion, '\n'
        ), 
        DEFAULT, 
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`alexis.gomez`@`%`*/ /*!50003 TRIGGER `tbd_departamentos_servicios_AFTER_DELETE` AFTER DELETE ON `tbd_departamentos_servicios` FOR EACH ROW BEGIN
 DECLARE v_departamento_nombre VARCHAR(100);
    DECLARE v_servicio_nombre VARCHAR(100);
    
    -- Obtener el nombre del departamento eliminado
    SELECT nombre INTO v_departamento_nombre
    FROM tbc_departamentos
    WHERE id = OLD.Departamento_ID;
    
    -- Obtener el nombre del servicio médico eliminado
    SELECT nombre INTO v_servicio_nombre
    FROM tbc_servicios_medicos
    WHERE id = OLD.Servicio_ID;
    
    INSERT INTO tbi_bitacora
    VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Delete',
        'tbd_departamentos_servicios',
        CONCAT_WS(' ',
            'Se ha eliminado un departamento-servicio con los siguientes datos:', '\n',
            'Departamento:', v_departamento_nombre, '\n',
            'Servicio Médico:', v_servicio_nombre, '\n',
            'Requisitos:', OLD.Requisitos, '\n',
            'Restricciones:', OLD.Restricciones, '\n',
            'Estatus:', 'Inactivo', '\n',
            'Fecha_Registro:', OLD.Fecha_Registro, '\n',
            'Fecha_Actualizacion:', OLD.Fecha_Actualizacion, '\n'
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_dispensaciones`
--

DROP TABLE IF EXISTS `tbd_dispensaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_dispensaciones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `RecetaMedica_id` int unsigned DEFAULT NULL,
  `PersonalMedico_id` int unsigned NOT NULL,
  `Departamento_id` int unsigned NOT NULL,
  `Solicitud_id` int unsigned DEFAULT NULL,
  `Estatus` enum('Abastecida','Parcialmente abastecida') NOT NULL,
  `Tipo` enum('Publica','Privada','Mixta') NOT NULL,
  `TotalMedicamentosEntregados` int NOT NULL,
  `Total_costo` float NOT NULL,
  `Fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_dispensaciones`
--

LOCK TABLES `tbd_dispensaciones` WRITE;
/*!40000 ALTER TABLE `tbd_dispensaciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_dispensaciones` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Cristian.Ojeda`@`%`*/ /*!50003 TRIGGER `tbd_dispensaciones_AFTER_INSERT` AFTER INSERT ON `tbd_dispensaciones` FOR EACH ROW BEGIN
 DECLARE v_estatus_new VARCHAR(50) DEFAULT NEW.Estatus;
    DECLARE v_tipo_new VARCHAR(50) DEFAULT NEW.Tipo;
    DECLARE v_solicitud_id VARCHAR(50);
    DECLARE v_receta_medica_id VARCHAR(50);

    IF NEW.Solicitud_id IS NULL THEN
        SET v_solicitud_id = 'no aplica';
    ELSE
        SET v_solicitud_id = CAST(NEW.Solicitud_id AS CHAR);
    END IF;

    IF NEW.RecetaMedica_id IS NULL THEN
        SET v_receta_medica_id = 'no aplica';
    ELSE
        SET v_receta_medica_id = CAST(NEW.RecetaMedica_id AS CHAR);
    END IF;

    INSERT INTO tbi_bitacora VALUES(
        DEFAULT,
        CURRENT_USER(),
        'Create',
        'tbb_dispensaciones',
        CONCAT_WS(' ', 
            'Se ha insertado una nueva dispensación con ID:', NEW.id, 
            '\nReceta Medica:', v_receta_medica_id, 
            '\nPersonal Medico:', NEW.PersonalMedico_id, 
            '\nDepartamento:', NEW.Departamento_id, 
            '\nSolicitud:', v_solicitud_id, 
            '\nEstatus:', v_estatus_new, 
            '\nTipo:', v_tipo_new, 
            '\nMedicamentos entregados:', NEW.TotalMedicamentosEntregados, 
            '\nCosto:', NEW.Total_costo
        ),
       default,
       default
    ); 


END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Cristian.Ojeda`@`%`*/ /*!50003 TRIGGER `tbd_dispensaciones_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_dispensaciones` FOR EACH ROW BEGIN
	set new.Fecha_Actualizacion = current_time();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Cristian.Ojeda`@`%`*/ /*!50003 TRIGGER `tbd_dispensaciones_AFTER_UPDATE` AFTER UPDATE ON `tbd_dispensaciones` FOR EACH ROW BEGIN
 DECLARE v_estatus_old VARCHAR(50) DEFAULT OLD.Estatus;
    DECLARE v_estatus_new VARCHAR(50) DEFAULT NEW.Estatus;
    DECLARE v_tipo_old VARCHAR(50) DEFAULT OLD.Tipo;
    DECLARE v_tipo_new VARCHAR(50) DEFAULT NEW.Tipo;

    -- Insertar en la bitácora
    INSERT INTO tbi_bitacora VALUES(
        DEFAULT,
        CURRENT_USER(),
        'Update',
        'tbb_dispensaciones',
        CONCAT_WS(' ', 
            'Se ha actualizado la dispensación con ID:', OLD.id, 
            '\n Receta Medica:', OLD.RecetaMedica_id, '-', NEW.RecetaMedica_id, 
            '\n Personal Medico:', OLD.PersonalMedico_id, '-', NEW.PersonalMedico_id, 
            '\n Departamento:', OLD.Departamento_id, '-', NEW.Departamento_id, 
            '\n Solicitud:', OLD.Solicitud_id, '-', NEW.Solicitud_id, 
            '\n Estatus:', v_estatus_old, '-', v_estatus_new, 
            '\n Tipo:', v_tipo_old, '-', v_tipo_new, 
            '\n Medicamentos entregados:', OLD.TotalMedicamentosEntregados, '-', NEW.TotalMedicamentosEntregados, 
            '\n Costo:', OLD.Total_costo, '-', NEW.Total_costo
        ),
        DEFAULT,
        DEFAULT
    ); 


END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Cristian.Ojeda`@`%`*/ /*!50003 TRIGGER `tbd_dispensaciones_AFTER_DELETE` AFTER DELETE ON `tbd_dispensaciones` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora VALUES(
        DEFAULT,
        CURRENT_USER(),
        'Delete',
        'tbb_dispensaciones',
        CONCAT_WS(' ', 
            'Se ha eliminado la dispensación con ID:', OLD.id, 
            '\n Receta Medica:', COALESCE(OLD.RecetaMedica_id, 'no aplica'), 
            '\n Solicitud: ', COALESCE(OLD.Solicitud_id, 'no aplica'),
            '\n Estatus:', OLD.Estatus
        ),
        DEFAULT,
        DEFAULT
    ); 

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_expedientes_clinicos`
--

DROP TABLE IF EXISTS `tbd_expedientes_clinicos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_expedientes_clinicos` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Persona_ID` int unsigned NOT NULL,
  `Antecendentes_Medicos_Patologicos` varchar(80) NOT NULL,
  `Antecendentes_Medicos_NoPatologicos` varchar(80) NOT NULL,
  `Antecendentes_Medicos_Patologicos_HeredoFamiliares` varchar(80) NOT NULL,
  `Interrogatorio_sistemas` varchar(80) NOT NULL,
  `Padecimiento_Actual` varchar(80) NOT NULL,
  `Notas_Medicas` varchar(80) DEFAULT NULL,
  `Estatus` bit(1) NOT NULL DEFAULT b'1',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  CONSTRAINT `fk_expedientes_1` FOREIGN KEY (`ID`) REFERENCES `tbb_personas` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_expedientes_clinicos`
--

LOCK TABLES `tbd_expedientes_clinicos` WRITE;
/*!40000 ALTER TABLE `tbd_expedientes_clinicos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_expedientes_clinicos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`arturo.aguilar`@`%`*/ /*!50003 TRIGGER `tbb_expedientes_clinicos_AFTER_INSERT` AFTER INSERT ON `tbd_expedientes_clinicos` FOR EACH ROW BEGIN
	declare v_estatus varchar(20) default 'Activo';
-- validamos el estatus del registro y le asignamos una etiqueta para la descripcion

	if not new.Estatus then
		set v_estatus = 'Inactivo';
    end if;
    
    INSERT INTO tbi_bitacora VALUES (
        default,
	    current_user(),
		'Create',
	   'tbb_expedientes_clinicos',
       concat_ws(' ','Se ha creado un nuevo EXPEDIENTE con los siguientes datos: \n',
		'PERSONA ID: ',new.persona_id, '\n', 
        'ANTECEDENTES MEDICOS PATOLOGICOS: ',new.Antecendentes_Medicos_Patologicos, '\n',
        'ANTECEDENTES MEDICOS NO PATOLOGICOS: ',new.Antecendentes_Medicos_NoPatologicos, '\n',
        'ANTECEDENTES MEDICOS PATOLOGICOS HEREDOFAMILIARES',new.Antecendentes_Medicos_Patologicos_HeredoFamiliares, '\n',
        'INTERROGATORIO DE SISTEMAS', new.Interrogatorio_sistemas,'\n',
        'PADECIMIENTO ACTUAL', new.Padecimiento_Actual,'\n',
        'NOTAS MEDICAS', new.Notas_Medicas,'\n',
        'ESTATUS: ',v_estatus,'\n'
        ),
		default,
		default
	);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`arturo.aguilar`@`%`*/ /*!50003 TRIGGER `tbb_expedientes_clinicos_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_expedientes_clinicos` FOR EACH ROW BEGIN
	set new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`arturo.aguilar`@`%`*/ /*!50003 TRIGGER `tbb_expedientes_clinicos_AFTER_UPDATE` AFTER UPDATE ON `tbd_expedientes_clinicos` FOR EACH ROW BEGIN
	declare v_estatus_old varchar(20) default 'Activo';
    declare v_estatus_new varchar(20) default 'Activo';
	-- validamos el estatus del registro y le asignamos una etiqueta para la descripcion

		if not new.Estatus then
			set v_estatus_new = 'Inactivo';
		end if;
        if not new.Estatus then
			set v_estatus_old = 'Inactivo';
		end if;
	
    INSERT INTO tbi_bitacora VALUES (
        default,
	    current_user(),
		'Update',
	   'tbb_expedientes_clinicos',
       concat_ws(' ','Se ha actualizado el EXPEDIENTE con los siguientes datos: \n',
		'PERSONA ID: ', old.persona_id,' -> ',new.persona_id, '\n', 
        'ANTECEDENTES MEDICOS PATOLOGICOS: ',old.Antecendentes_Medicos_Patologicos,' -> ',new.Antecendentes_Medicos_Patologicos, '\n',
        'ANTECEDENTES MEDICOS NO PATOLOGICOS: ',old.Antecendentes_Medicos_NoPatologicos,' -> ',new.Antecendentes_Medicos_NoPatologicos, '\n',
        'ANTECEDENTES MEDICOS PATOLOGICOS HEREDOFAMILIARES',old.Antecendentes_Medicos_Patologicos_HeredoFamiliares,' -> ',new.Antecendentes_Medicos_Patologicos_HeredoFamiliares, '\n',
        'INTERROGATORIO DE SISTEMAS',old.Interrogatorio_sistemas,' -> ', new.Interrogatorio_sistemas,'\n',
        'PADECIMIENTO ACTUAL',old.Padecimiento_Actual,' -> ', new.Padecimiento_Actual,'\n',
        'NOTAS MEDICAS',old.Notas_Medicas,' -> ', new.Notas_Medicas,'\n',
        'ESTATUS: ', v_estatus_old,'->',v_estatus_new,'\n'
        ),
		default,
		default
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`arturo.aguilar`@`%`*/ /*!50003 TRIGGER `tbb_expedientes_clinicos_AFTER_DELETE` AFTER DELETE ON `tbd_expedientes_clinicos` FOR EACH ROW BEGIN
	declare v_estatus varchar(20) default 'Activo';
		
		-- validamos el estatus del registro y le asignamos una etiqueta para la descripcion

			if not old.Estatus then
				set v_estatus = 'Inactivo';
			end if;
            
	INSERT INTO tbi_bitacora VALUES (
        default,
	    current_user(),
		'Delete',
	   'tbb_expedientes_clinicos',
       concat_ws(' ','Se ha eliminado el EXPEDIENTE con los siguientes datos: \n',
		'PERSONA ID: ', old.persona_id, '\n', 
        'ANTECEDENTES MEDICOS PATOLOGICOS: ',old.Antecendentes_Medicos_Patologicos, '\n',
        'ANTECEDENTES MEDICOS NO PATOLOGICOS: ',old.Antecendentes_Medicos_NoPatologicos, '\n',
        'ANTECEDENTES MEDICOS PATOLOGICOS HEREDOFAMILIARES',old.Antecendentes_Medicos_Patologicos_HeredoFamiliares, '\n',
        'INTERROGATORIO DE SISTEMAS',old.Interrogatorio_sistemas,'\n',
        'PADECIMIENTO ACTUAL',old.Padecimiento_Actual,'\n',
        'NOTAS MEDICAS',old.Notas_Medicas,'\n',
        'ESTATUS: ', v_estatus,'\n'
        ),
		default,
		default
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_horarios`
--

DROP TABLE IF EXISTS `tbd_horarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_horarios` (
  `horario_id` int NOT NULL AUTO_INCREMENT,
  `empleado_id` int NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `especialidad` varchar(100) NOT NULL,
  `dia_semana` varchar(20) NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_fin` time NOT NULL,
  `turno` varchar(20) NOT NULL,
  `nombre_departamento` varchar(100) NOT NULL,
  `nombre_sala` varchar(100) NOT NULL,
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`horario_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_horarios`
--

LOCK TABLES `tbd_horarios` WRITE;
/*!40000 ALTER TABLE `tbd_horarios` DISABLE KEYS */;
INSERT INTO `tbd_horarios` VALUES (1,1,'Marvin','Traumatologia','Lunes','10:10:00','11:10:00','Matutino','Dep1','Sala1','2024-06-20 16:14:38','2024-06-20 16:14:38'),(2,1,'Doctor 1','Especialidad 1','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 2','2024-06-20 16:15:57','2024-06-20 16:15:57'),(3,2,'Doctor 2','Especialidad 2','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 1','2024-06-20 16:15:57','2024-06-20 16:15:57'),(4,3,'Doctor 3','Especialidad 3','Lunes','08:00:00','16:00:00','Matutino','Departamento 1','Sala 2','2024-06-20 16:15:57','2024-06-20 16:15:57'),(5,4,'Doctor 4','Especialidad 4','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 1','2024-06-20 16:15:57','2024-06-20 16:15:57'),(6,5,'Doctor 5','Especialidad 5','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 2','2024-06-20 16:15:57','2024-06-20 16:15:57');
/*!40000 ALTER TABLE `tbd_horarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`DiegoOliver`@`%`*/ /*!50003 TRIGGER `tbd_horarios_AFTER_INSERT` AFTER INSERT ON `tbd_horarios` FOR EACH ROW BEGIN
    INSERT INTO tbi_bitacora (
        Usuario,
        Operacion,
        Tabla,
        Descripcion,
        Estatus,
        Fecha_Registro
    ) VALUES (
        CURRENT_USER(),
        'Create',
        'tbd_horarios',
        CONCAT_WS(' ', 'Se ha agregado un nuevo horario con los siguientes datos:',
            '\n ID Empleado:', NEW.empleado_id,
            '\n Nombre:', NEW.nombre,
            '\n Especialidad:', NEW.especialidad,
            '\n Día de la Semana:', NEW.dia_semana,
            '\n Hora de Inicio:', NEW.hora_inicio,
            '\n Hora de Fin:', NEW.hora_fin,
            '\n Turno:', NEW.turno,
            '\n Departamento:', NEW.nombre_departamento,
            '\n Sala:', NEW.nombre_sala),
        b'1',
        CURRENT_TIMESTAMP()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`DiegoOliver`@`%`*/ /*!50003 TRIGGER `tbd_horarios_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_horarios` FOR EACH ROW BEGIN
    -- No es necesario establecer NEW.fecha_actualizacion porque se maneja automáticamente por el campo de la tabla
    
    INSERT INTO tbi_bitacora (
        Usuario,
        Operacion,
        Tabla,
        Descripcion,
        Estatus,
        Fecha_Registro
    ) VALUES (
        CURRENT_USER(),
        'Update',
        'tbd_horarios',
        CONCAT_WS(' ', 'Se ha actualizado un horario con los siguientes cambios:',
            '\n ID Empleado:', OLD.empleado_id, '->', NEW.empleado_id,
            '\n Nombre:', OLD.nombre, '->', NEW.nombre,
            '\n Especialidad:', OLD.especialidad, '->', NEW.especialidad,
            '\n Día de la Semana:', OLD.dia_semana, '->', NEW.dia_semana,
            '\n Hora de Inicio:', OLD.hora_inicio, '->', NEW.hora_inicio,
            '\n Hora de Fin:', OLD.hora_fin, '->', NEW.hora_fin,
            '\n Turno:', OLD.turno, '->', NEW.turno,
            '\n Departamento:', OLD.nombre_departamento, '->', NEW.nombre_departamento,
            '\n Sala:', OLD.nombre_sala, '->', NEW.nombre_sala),
        b'1',
        CURRENT_TIMESTAMP()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`DiegoOliver`@`%`*/ /*!50003 TRIGGER `tbd_horarios_AFTER_UPDATE` AFTER UPDATE ON `tbd_horarios` FOR EACH ROW BEGIN
    DECLARE v_turno_old VARCHAR(20) DEFAULT 'Activo';
    DECLARE v_turno_new VARCHAR(20) DEFAULT 'Activo';

    -- Validamos el turno del registro y le asignamos una etiqueta para la descripción
    IF NEW.turno = 'Inactivo' THEN
        SET v_turno_new = 'Inactivo';
    ELSEIF NEW.turno = 'Bloqueado' THEN
        SET v_turno_new = 'Bloqueado';
    ELSEIF NEW.turno = 'Suspendido' THEN
        SET v_turno_new = 'Suspendido';
    END IF;

    IF OLD.turno = 'Inactivo' THEN
        SET v_turno_old = 'Inactivo';
    ELSEIF OLD.turno = 'Bloqueado' THEN
        SET v_turno_old = 'Bloqueado';
    ELSEIF OLD.turno = 'Suspendido' THEN
        SET v_turno_old = 'Suspendido';
    END IF;

    INSERT INTO tbi_bitacora (
        Usuario,
        Operacion,
        Tabla,
        Descripcion,
        Estatus,
        Fecha_Registro
    ) VALUES (
        CURRENT_USER(),
        'Update',
        'tbd_horarios',
        CONCAT_WS(' ', 'Se ha modificado el horario existente con los siguientes datos:',
            '\n ID Empleado:', OLD.empleado_id, '-', NEW.empleado_id,
            '\n Nombre:', OLD.nombre, '-', NEW.nombre,
            '\n Especialidad:', OLD.especialidad, '-', NEW.especialidad,
            '\n Día de la Semana:', OLD.dia_semana, '-', NEW.dia_semana,
            '\n Hora de Inicio:', OLD.hora_inicio, '-', NEW.hora_inicio,
            '\n Hora de Fin:', OLD.hora_fin, '-', NEW.hora_fin,
            '\n Turno:', v_turno_old, '-', v_turno_new,
            '\n Departamento:', OLD.nombre_departamento, '-', NEW.nombre_departamento,
            '\n Sala:', OLD.nombre_sala, '-', NEW.nombre_sala),
        b'1',
        CURRENT_TIMESTAMP()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`DiegoOliver`@`%`*/ /*!50003 TRIGGER `tbd_horarios_AFTER_DELETE` AFTER DELETE ON `tbd_horarios` FOR EACH ROW BEGIN
    DECLARE v_turno VARCHAR(20) DEFAULT 'Activo';

    INSERT INTO tbi_bitacora (
        Usuario,
        Operacion,
        Tabla,
        Descripcion,
        Estatus,
        Fecha_Registro
    ) VALUES (
        CURRENT_USER(),
        'Delete',
        'tbd_horarios',
        CONCAT_WS(' ', 'Se ha eliminado un horario con los siguientes datos:',
            '\n ID Empleado:', OLD.empleado_id,
            '\n Nombre:', OLD.nombre,
            '\n Especialidad:', OLD.especialidad,
            '\n Día de la Semana:', OLD.dia_semana,
            '\n Hora de Inicio:', OLD.hora_inicio,
            '\n Hora de Fin:', OLD.hora_fin,
            '\n Turno:', v_turno,
            '\n Departamento:', OLD.nombre_departamento,
            '\n Sala:', OLD.nombre_sala),
        b'1',
        CURRENT_TIMESTAMP()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_lotes_medicamentos`
--

DROP TABLE IF EXISTS `tbd_lotes_medicamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_lotes_medicamentos` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Medicamento_ID` int unsigned NOT NULL,
  `Personal_Medico_ID` int unsigned NOT NULL,
  `Clave` varchar(50) NOT NULL,
  `Estatus` enum('Reservado','En transito','Recibido','Rechazado') NOT NULL,
  `Costo_Total` decimal(10,2) NOT NULL,
  `Cantidad` int unsigned NOT NULL,
  `Ubicacion` varchar(100) NOT NULL,
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_lotes_medicamentos`
--

LOCK TABLES `tbd_lotes_medicamentos` WRITE;
/*!40000 ALTER TABLE `tbd_lotes_medicamentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_lotes_medicamentos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`myriam.valderrabano`@`%`*/ /*!50003 TRIGGER `tbd_lotes_medicamentos_AFTER_INSERT` AFTER INSERT ON `tbd_lotes_medicamentos` FOR EACH ROW BEGIN

	DECLARE v_estatus_descripcion VARCHAR(20) DEFAULT 'Reservado';

    -- Validamos el estatus del registro y le asignamos una etiqueta para la descripción
    IF NEW.Estatus = 'Reservado' THEN
        SET v_estatus_descripcion = 'Reservado';
    ELSEIF NEW.Estatus = 'En transito' THEN
        SET v_estatus_descripcion = 'En transito';
    ELSEIF NEW.Estatus = 'Recibido' THEN
        SET v_estatus_descripcion = 'Recibido';
    ELSEIF NEW.Estatus = 'Rechazado' THEN
        SET v_estatus_descripcion = 'Rechazado';
    END IF;

    -- Insertamos el evento en la bitácora
    INSERT INTO tbi_bitacora VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Create',
        'tbb_lotes_medicamentos',
        CONCAT_WS(' ', 'Se ha insertado un nuevo lote de medicamento con ID:', NEW.ID,
        '\n Medicamento_ID:', NEW.Medicamento_ID,
        '\n Personal_Medico_ID:', NEW.Personal_Medico_ID,
        '\n Clave:', NEW.Clave,
        '\n Estatus:', NEW.Estatus,
        '\n Costo_Total:', NEW.Costo_Total,
        '\n Cantidad:', NEW.Cantidad,
        '\n y Ubicacion:', NEW.Ubicacion),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`myriam.valderrabano`@`%`*/ /*!50003 TRIGGER `tbd_lotes_medicamentos_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_lotes_medicamentos` FOR EACH ROW BEGIN
	set new.Fecha_Actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`myriam.valderrabano`@`%`*/ /*!50003 TRIGGER `tbd_lotes_medicamentos_AFTER_UPDATE` AFTER UPDATE ON `tbd_lotes_medicamentos` FOR EACH ROW BEGIN
	DECLARE v_estatus_descripcion VARCHAR(20);

    -- Asignamos una descripción al estatus del lote de medicamento
    CASE NEW.Estatus
        WHEN 'Reservado' THEN SET v_estatus_descripcion := 'Reservado';
        WHEN 'En transito' THEN SET v_estatus_descripcion := 'En transito';
        WHEN 'Recibido' THEN SET v_estatus_descripcion := 'Recibido';
        WHEN 'Rechazado' THEN SET v_estatus_descripcion := 'Rechazado';
    END CASE;

    -- Insertamos el evento en la bitácora
    INSERT INTO tbi_bitacora VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Update',
        'tbb_lotes_medicamentos',
        CONCAT_WS(' ', 
            'Se ha actualización el Lote Medicamento:',
            '\n ID del Lote:', OLD.ID,
            '\n Medicamento_ID:', OLD.Medicamento_ID, '-', NEW.Medicamento_ID,
            '\n Personal_Medico_ID:', OLD.Personal_Medico_ID, '-', NEW.Personal_Medico_ID,
            '\n Clave:', OLD.Clave, '-', NEW.Clave,
            '\n Estatus:', OLD.Estatus, '-', v_estatus_descripcion,
            '\n Costo Total:', OLD.Costo_Total, '-', NEW.Costo_Total,
            '\n Cantidad:', OLD.Cantidad, '-', NEW.Cantidad,
            '\n y Ubicación:', OLD.Ubicacion, '-', NEW.Ubicacion
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`myriam.valderrabano`@`%`*/ /*!50003 TRIGGER `tbd_lotes_medicamentos_AFTER_DELETE` AFTER DELETE ON `tbd_lotes_medicamentos` FOR EACH ROW BEGIN
	DECLARE v_estatus_descripcion VARCHAR(20);

    -- Asignamos una descripción al estatus del lote de medicamento
    CASE OLD.Estatus
        WHEN 'Reservado' THEN SET v_estatus_descripcion := 'Reservado';
        WHEN 'En transito' THEN SET v_estatus_descripcion := 'En transito';
        WHEN 'Recibido' THEN SET v_estatus_descripcion := 'Recibido';
        WHEN 'Rechazado' THEN SET v_estatus_descripcion := 'Rechazado';
    END CASE;

    -- Insertamos el evento en la bitácora
    INSERT INTO tbi_bitacora VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Delete',
        'tbb_lotes_medicamentos',
        CONCAT_WS(' ', 
            'Se ha eliminado el Lote Medicamento con:',
            '\n ID del Lote:', OLD.ID,
            '\nMedicamento_ID:', OLD.Medicamento_ID,
            '\n Personal_Medico_ID:', OLD.Personal_Medico_ID,
            '\n Clave:', OLD.Clave,
            '\n Estatus:', v_estatus_descripcion,
            '\n Costo Total:', OLD.Costo_Total,
            '\nCantidad:', OLD.Cantidad,
            '\n y con Ubicación:', OLD.Ubicacion
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_puestos_departamentos`
--

DROP TABLE IF EXISTS `tbd_puestos_departamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_puestos_departamentos` (
  `PuestoID` int unsigned NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `Salario` decimal(10,2) DEFAULT NULL,
  `Turno` enum('Mañana','Tarde','Noche') DEFAULT NULL,
  `Creado` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `Modificado` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `DepartamentoID` int unsigned NOT NULL,
  PRIMARY KEY (`PuestoID`),
  KEY `DepartamentoID` (`DepartamentoID`),
  CONSTRAINT `tbd_puestos_departamentos_ibfk_1` FOREIGN KEY (`DepartamentoID`) REFERENCES `tbc_departamentos` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_puestos_departamentos`
--

LOCK TABLES `tbd_puestos_departamentos` WRITE;
/*!40000 ALTER TABLE `tbd_puestos_departamentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_puestos_departamentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbd_receta_medicamentos`
--

DROP TABLE IF EXISTS `tbd_receta_medicamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_receta_medicamentos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_receta` int unsigned NOT NULL,
  `id_medicamento` int unsigned NOT NULL,
  `cantidad` int unsigned NOT NULL,
  `indicaciones` varchar(250) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_medicamento_receta_1` (`id_medicamento`),
  KEY `fk_receta_medicamento_1` (`id_receta`),
  CONSTRAINT `fk_medicamento_receta_1` FOREIGN KEY (`id_medicamento`) REFERENCES `tbc_medicamentos` (`ID`),
  CONSTRAINT `fk_receta_medicamento_1` FOREIGN KEY (`id_receta`) REFERENCES `tbd_recetas_medicas` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_receta_medicamentos`
--

LOCK TABLES `tbd_receta_medicamentos` WRITE;
/*!40000 ALTER TABLE `tbd_receta_medicamentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_receta_medicamentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbd_recetas_detalles`
--

DROP TABLE IF EXISTS `tbd_recetas_detalles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_recetas_detalles` (
  `id_receta` int unsigned NOT NULL,
  `observaciones` varchar(255) NOT NULL,
  `recomendaciones` text NOT NULL,
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `fk_recetas_detalles2_idx` (`id_receta`),
  CONSTRAINT `fk_recetas_detalles2` FOREIGN KEY (`id_receta`) REFERENCES `tbd_recetas_medicas` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_recetas_detalles`
--

LOCK TABLES `tbd_recetas_detalles` WRITE;
/*!40000 ALTER TABLE `tbd_recetas_detalles` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_recetas_detalles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbd_recetas_medicas`
--

DROP TABLE IF EXISTS `tbd_recetas_medicas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_recetas_medicas` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `fecha_cita` datetime NOT NULL,
  `fecha_actualizacion` date DEFAULT NULL,
  `diagnostico` varchar(255) NOT NULL,
  `id_paciente` int unsigned NOT NULL,
  `id_medico` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_recetas_pacientes_idx` (`id_medico`),
  KEY `fk_receta_paciente_idx` (`id_paciente`),
  CONSTRAINT `fk_receta_medico_2` FOREIGN KEY (`id_medico`) REFERENCES `tbb_personal_medico` (`Persona_ID`),
  CONSTRAINT `fk_receta_paciente_2` FOREIGN KEY (`id_paciente`) REFERENCES `tbb_pacientes` (`Persona_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_recetas_medicas`
--

LOCK TABLES `tbd_recetas_medicas` WRITE;
/*!40000 ALTER TABLE `tbd_recetas_medicas` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_recetas_medicas` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`marvin.tolentino`@`%`*/ /*!50003 TRIGGER `tbd_recetas_medicas_AFTER_INSERT` AFTER INSERT ON `tbd_recetas_medicas` FOR EACH ROW BEGIN
DECLARE v_usuario INT DEFAULT NEW.id_paciente;
 INSERT INTO tbi_bitacora 
    VALUES (
    default,
	current_user(),
    'Create',
    'tbd_recetas_medicas',
    CONCAT_WS(' ', 'Se ha creado una nueva receta médica con ID: ',NEW.id,'\n',
    "Para el paciente con id:",v_usuario),
    default, 
    default);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`marvin.tolentino`@`%`*/ /*!50003 TRIGGER `tbd_recetas_medicas_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_recetas_medicas` FOR EACH ROW BEGIN
SET new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`marvin.tolentino`@`%`*/ /*!50003 TRIGGER `tbd_recetas_medicas_AFTER_UPDATE` AFTER UPDATE ON `tbd_recetas_medicas` FOR EACH ROW BEGIN
   
    INSERT INTO tbi_bitacora 
    VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Update',
        'tbd_recetas_medicas',
         CONCAT_WS(' ', 
        'Se ha actualizado la receta médica con ID: ', NEW.id,'\n',
        'Fecha de cita Actual:', old.fecha_cita,'\n',
        'Fecha de cita  Actualizado:',new.fecha_cita,'\n',
        'Diagnostico Actual:', old.diagnostico,'\n',
        'Diagnostico Actualizado:',new.diagnostico,'\n'
        ),
        
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`marvin.tolentino`@`%`*/ /*!50003 TRIGGER `tbd_recetas_medicas_AFTER_DELETE` AFTER DELETE ON `tbd_recetas_medicas` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora VALUES (
    DEFAULT,
    CURRENT_USER(),
    'Delete',
    'tbd_recetas_medicas',
    CONCAT_WS(' ', 
		'se ha eliminado la receta con id:', old.id),
    DEFAULT,
    DEFAULT
);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_resultados_estudios`
--

DROP TABLE IF EXISTS `tbd_resultados_estudios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_resultados_estudios` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Paciente_ID` int unsigned NOT NULL,
  `Personal_Medico_ID` int unsigned NOT NULL,
  `Estudio_ID` int unsigned NOT NULL,
  `Folio` varchar(11) NOT NULL,
  `Resultados` text NOT NULL,
  `Observaciones` text NOT NULL,
  `Estatus` enum('Pendiente','En Proceso','Completado','Aprobado','Rechazado') DEFAULT NULL,
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Folio` (`Folio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_resultados_estudios`
--

LOCK TABLES `tbd_resultados_estudios` WRITE;
/*!40000 ALTER TABLE `tbd_resultados_estudios` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_resultados_estudios` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`armando.carrasco`@`%`*/ /*!50003 TRIGGER `tbd_resultados_estudios_AFTER_INSERT` AFTER INSERT ON `tbd_resultados_estudios` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora
    VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Create',
        'tbd_resultados_estudios',
        CONCAT_WS(' ',
            'Se ha registrado un nuevo resultado de estudio con los siguientes datos:','\n',
            'PACIENTE_ID:', NEW.Paciente_ID,'\n',
            'PERSONAL_MEDICO_ID:', NEW.Personal_Medico_ID,'\n',
            'ESTUDIO_ID:', NEW.Estudio_ID,'\n',
            'FOLIO:', NEW.Folio,'\n',
            'RESULTADOS:', NEW.Resultados,'\n',
            'OBSERVACIONES:', NEW.Observaciones,'\n',
            'ESTATUS:', new.estatus,'\n'
        ),
        DEFAULT,
        DEFAULT
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`armando.carrasco`@`%`*/ /*!50003 TRIGGER `tbd_resultados_estudios_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_resultados_estudios` FOR EACH ROW BEGIN
	set new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`armando.carrasco`@`%`*/ /*!50003 TRIGGER `tbd_resultados_estudios_AFTER_UPDATE` AFTER UPDATE ON `tbd_resultados_estudios` FOR EACH ROW BEGIN
    INSERT INTO tbi_bitacora 
    VALUES (
        DEFAULT, 
        CURRENT_USER(), 
        'Update', 
        'tbd_resultados_estudios', 
        CONCAT_WS(' ', 
            'Se ha modificado un resultado de estudio con ID:', OLD.ID, 'con los siguientes datos:', '\n',
            'PACIENTE_ID:', OLD.Paciente_ID, '-', NEW.Paciente_ID, '\n',
            'PERSONAL_MEDICO_ID:', OLD.Personal_Medico_ID, '-', NEW.Personal_Medico_ID, '\n',
            'ESTUDIO_ID:', OLD.Estudio_ID, '-', NEW.Estudio_ID, '\n',
            'FOLIO:', OLD.Folio, '-', NEW.Folio, '\n',
            'RESULTADOS:', OLD.Resultados, '-', NEW.Resultados, '\n',
            'OBSERVACIONES:', OLD.Observaciones, '-', NEW.Observaciones, '\n',
            'ESTATUS:', OLD.Estatus, '-', NEW.Estatus,'\n'
        ), 
        DEFAULT, 
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`armando.carrasco`@`%`*/ /*!50003 TRIGGER `tbd_resultados_estudios_AFTER_DELETE` AFTER DELETE ON `tbd_resultados_estudios` FOR EACH ROW BEGIN
 INSERT INTO tbi_bitacora
    VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Delete',
        'tbd_resultados_estudios',
        CONCAT_WS(' ',
            'Se ha eliminado un nuevo resultado de estudio con los siguientes datos:','\n',
            'PACIENTE_ID:', old.Paciente_ID,'\n',
            'PERSONAL_MEDICO_ID:', old.Personal_Medico_ID,'\n',
            'ESTUDIO_ID:', old.Estudio_ID,'\n',
            'FOLIO:', old.Folio,'\n',
            'RESULTADOS:', old.Resultados,'\n',
            'OBSERVACIONES:', old.Observaciones,'\n',
            'ESTATUS:', old.estatus,'\n'
        ),
        DEFAULT,
        DEFAULT
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_solicitudes`
--

DROP TABLE IF EXISTS `tbd_solicitudes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_solicitudes` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Paciente_ID` int unsigned NOT NULL,
  `Medico_ID` int unsigned NOT NULL,
  `Servicio_ID` int unsigned NOT NULL,
  `Prioridad` enum('Urgente','Alta','Moderada','Emergente','Normal') NOT NULL,
  `Descripcion` text NOT NULL,
  `Estatus` enum('Registrada','Programada','Cancelada','Reprogramada','En Proceso','Realizada') NOT NULL DEFAULT 'Registrada',
  `Estatus_Aprobacion` bit(1) NOT NULL DEFAULT b'0',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `fk_personal_medico_1_idx` (`Medico_ID`),
  KEY `fk_paciente_1_idx` (`Paciente_ID`),
  KEY `fk_servicios_medicos_2_idx` (`Servicio_ID`),
  CONSTRAINT `fk_paciente_1` FOREIGN KEY (`Paciente_ID`) REFERENCES `tbb_pacientes` (`Persona_ID`),
  CONSTRAINT `fk_personal_medico_1` FOREIGN KEY (`Medico_ID`) REFERENCES `tbb_personal_medico` (`Persona_ID`),
  CONSTRAINT `fk_servicios_medicos_2` FOREIGN KEY (`Servicio_ID`) REFERENCES `tbc_servicios_medicos` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_solicitudes`
--

LOCK TABLES `tbd_solicitudes` WRITE;
/*!40000 ALTER TABLE `tbd_solicitudes` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_solicitudes` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Carlos.Hernandez`@`%`*/ /*!50003 TRIGGER `tbd_solicitudes_AFTER_INSERT` AFTER INSERT ON `tbd_solicitudes` FOR EACH ROW BEGIN
   DECLARE nombre_paciente VARCHAR(150) DEFAULT NULL;
   DECLARE nombre_medico VARCHAR(100) DEFAULT NULL;
   DECLARE nombre_servicio VARCHAR(100) DEFAULT NULL;
   
   -- Obtener el nombre del paciente recién insertado
   SET nombre_paciente = (SELECT CONCAT_WS(" ", p.Nombre, p.Primer_Apellido, p.Segundo_Apellido)
                         FROM tbb_personas p
                         WHERE p.id = NEW.paciente_ID);

   -- Obtener el nombre del personal médico recién insertado
   SET nombre_medico = (SELECT CONCAT_WS(" ", p.Nombre, p.Primer_Apellido, p.Segundo_Apellido)
                         FROM tbb_personas p
                         WHERE p.id = NEW.medico_ID);
                         
   -- Obtener el nombre del servicio recién insertado
   SET nombre_servicio = (SELECT nombre FROM tbc_servicios_medicos s WHERE s.id = NEW.servicio_ID);

   INSERT INTO tbi_bitacora VALUES (
      DEFAULT, 
      CURRENT_USER(), 
      "Create", 
      "tbd_solicitudes", 
      CONCAT_WS(" ", 'Se ha creado una nueva solicitud con los siguientes datos: ',
      'ID: ', NEW.ID, '\n',
      'Nombre del Paciente: ', nombre_paciente, '\n',
      'Nombre del Medico: ', nombre_medico, '\n',
      'Nombre del Servicio: ', nombre_servicio, '\n',
      'Prioridad: ', NEW.prioridad, '\n',
      'Descripcion: ', NEW.descripcion, '\n',
      'Estatus de la solicitud: ', NEW.estatus, '\n',
      'Estatus de Aprobación: ', NEW.estatus_aprobacion), '\n',
      DEFAULT,
      DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Carlos.Hernandez`@`%`*/ /*!50003 TRIGGER `tbd_solicitudes_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_solicitudes` FOR EACH ROW BEGIN
	set new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Carlos.Hernandez`@`%`*/ /*!50003 TRIGGER `tbd_solicitudes_AFTER_UPDATE` AFTER UPDATE ON `tbd_solicitudes` FOR EACH ROW BEGIN
   DECLARE nombre_paciente_new VARCHAR(150) DEFAULT NULL;
   DECLARE nombre_medico_new VARCHAR(100) DEFAULT NULL;
   DECLARE nombre_servicio_new VARCHAR(100) DEFAULT NULL;
   DECLARE nombre_paciente_old VARCHAR(150) DEFAULT NULL;
   DECLARE nombre_medico_old VARCHAR(100) DEFAULT NULL;
   DECLARE nombre_servicio_old VARCHAR(100) DEFAULT NULL;
   
   -- Obtener el nombre del paciente antes y después de la actualización
   SET nombre_paciente_new = (SELECT CONCAT_WS(" ", p.Nombre, p.Primer_Apellido, p.Segundo_Apellido)
                             FROM tbb_personas p
                             WHERE p.id = NEW.paciente_ID);
   SET nombre_paciente_old = (SELECT CONCAT_WS(" ", p.Nombre, p.Primer_Apellido, p.Segundo_Apellido)
                             FROM tbb_personas p
                             WHERE p.id = OLD.paciente_ID);

   -- Obtener el nombre del personal medico antes y después de la actualización
   SET nombre_medico_new = (SELECT CONCAT_WS(" ", p.Nombre, p.Primer_Apellido, p.Segundo_Apellido)
                           FROM tbb_personas p
                           WHERE p.id = NEW.medico_ID);
   SET nombre_medico_old = (SELECT CONCAT_WS(" ", p.Nombre, p.Primer_Apellido, p.Segundo_Apellido)
                           FROM tbb_personas p
                           WHERE p.id = OLD.medico_ID);
                         
   -- Obtener el nombre del servicio antes y después de la actualización
   SET nombre_servicio_new = (SELECT nombre FROM tbc_servicios_medicos s WHERE s.id = NEW.servicio_ID);
   SET nombre_servicio_old = (SELECT nombre FROM tbc_servicios_medicos s WHERE s.id = OLD.servicio_ID);

   INSERT INTO tbi_bitacora VALUES (
      DEFAULT, 
      CURRENT_USER(), 
      "Update", 
      "tbd_solicitudes", 
      CONCAT_WS(" ", 'Se ha modificado una solicitud con el ID: ', OLD.ID, 'Con los siguientes datos:',
      'Nombre del Paciente: ', nombre_paciente_old, ' - ', nombre_paciente_new, '\n',
      'Nombre del Medico: ', nombre_medico_old, ' - ', nombre_medico_new, '\n',
      'Nombre del Servicio: ', nombre_servicio_old, ' - ', nombre_servicio_new, '\n',
      'Prioridad: ', OLD.prioridad, ' - ', NEW.prioridad, '\n',
      'Descripcion: ', OLD.descripcion, ' - ', NEW.descripcion, '\n',
      'Estatus de la solicitud: ', OLD.estatus, ' - ', NEW.estatus, '\n',
      'Estatus de Aprobación: ', OLD.estatus_aprobacion, ' - ', NEW.estatus_aprobacion), '\n',
      DEFAULT,
      DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`Carlos.Hernandez`@`%`*/ /*!50003 TRIGGER `tbd_solicitudes_AFTER_DELETE` AFTER DELETE ON `tbd_solicitudes` FOR EACH ROW BEGIN
   INSERT INTO tbi_bitacora VALUES (
      DEFAULT, 
      CURRENT_USER(), 
      "Delete", 
      "tbd_solicitudes", 
      CONCAT_WS(" ", 'Se ha eliminado una solicitud existente con los siguientes datos: ',
      'ID: ', OLD.ID, '\n',
      'Nombre del Paciente: ', OLD.paciente_ID, '\n',
      'Nombre del Medico: ', OLD.medico_ID, '\n',
      'Nombre del Servicio: ', OLD.servicio_ID, '\n',
      'Prioridad: ', OLD.prioridad, '\n',
      'Descripcion: ', OLD.descripcion, '\n',
      'Estatus de la solicitud: ', OLD.estatus, '\n',
      'Estatus de Aprobación: ', OLD.estatus_aprobacion), '\n',
      DEFAULT,
      DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_usuarios_roles`
--

DROP TABLE IF EXISTS `tbd_usuarios_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_usuarios_roles` (
  `Usuario_ID` int unsigned NOT NULL,
  `Rol_ID` int unsigned NOT NULL,
  `Estatus` bit(1) DEFAULT b'1',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`Usuario_ID`,`Rol_ID`),
  KEY `Rol_ID` (`Rol_ID`),
  CONSTRAINT `tbd_usuarios_roles_ibfk_1` FOREIGN KEY (`Usuario_ID`) REFERENCES `tbb_usuarios` (`ID`),
  CONSTRAINT `tbd_usuarios_roles_ibfk_2` FOREIGN KEY (`Rol_ID`) REFERENCES `tbc_roles` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_usuarios_roles`
--

LOCK TABLES `tbd_usuarios_roles` WRITE;
/*!40000 ALTER TABLE `tbd_usuarios_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_usuarios_roles` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_usuarios_roles_AFTER_INSERT` AFTER INSERT ON `tbd_usuarios_roles` FOR EACH ROW BEGIN
DECLARE v_email_usuario VARCHAR(60) DEFAULT (SELECT correo_electronico FROM 
    tbb_usuarios WHERE id = new.usuario_id);
    DECLARE v_nombre_rol VARCHAR(50) DEFAULT (SELECT nombre FROM 
    tbc_roles WHERE id = new.rol_id);
    DECLARE v_estatus VARCHAR(20) DEFAULT 'Activo';
    
    -- Validamos el estatus para asignarle su valor textual
    IF NOT new.estatus THEN
     SET v_estatus= "Inactivo";
	END IF;
    
    
INSERT INTO tbi_bitacora VALUES
    (DEFAULT,
    current_user(), 
    'Create', 
    'tbd_usuarios_roles', 
    CONCAT_WS(' ','Se le ha asignado el ROL de :',
    v_nombre_rol,  ' al USUARIO con CORREO ELECTRÓNICO: ', v_email_usuario, 
    'y el ESTATUS: ', v_estatus),DEFAULT, DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_usuarios_roles_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_usuarios_roles` FOR EACH ROW BEGIN
SET new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_usuarios_roles_AFTER_UPDATE` AFTER UPDATE ON `tbd_usuarios_roles` FOR EACH ROW BEGIN
	DECLARE v_email_usuario VARCHAR(60) DEFAULT (SELECT correo_electronico FROM 
    tbb_usuarios WHERE id = old.usuario_id);
    DECLARE v_nombre_rol_old VARCHAR(50) DEFAULT (SELECT nombre FROM 
    tbc_roles WHERE id = old.rol_id);
    DECLARE v_nombre_rol_new VARCHAR(50) DEFAULT (SELECT nombre FROM 
    tbc_roles WHERE id = new.rol_id);
    DECLARE v_estatus VARCHAR(20) DEFAULT 'Activo';
    
    -- Validamos el estatus para asignarle su valor textual
    IF NOT old.estatus THEN
     SET v_estatus= "Inactivo";
	END IF;
    
    
INSERT INTO tbi_bitacora VALUES
    (DEFAULT,
    current_user(), 
    'Update', 
    'tbd_usuarios_roles', 
    CONCAT_WS(' ','Se le actualizado el ROL de :',
    v_nombre_rol_old, ' a: ', v_nombre_rol_new,  ' al USUARIO con CORREO ELECTRÓNICO: ', v_email_usuario, 
    'y el ESTATUS: ', v_estatus),DEFAULT, DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_usuarios_roles_AFTER_DELETE` AFTER DELETE ON `tbd_usuarios_roles` FOR EACH ROW BEGIN
	
	DECLARE v_email_usuario VARCHAR(60) DEFAULT (SELECT correo_electronico FROM 
    tbb_usuarios WHERE id = old.usuario_id);
    DECLARE v_nombre_rol VARCHAR(50) DEFAULT (SELECT nombre FROM 
    tbc_roles WHERE id = old.rol_id);
    DECLARE v_estatus VARCHAR(20) DEFAULT 'Activo';
    -- Verificamos el estatus del rol , para ubicar el valor en la descripción 
    -- de la bitácora
    IF NOT old.estatus THEN 
      SET v_estatus = 'Inactivo';
	END IF; 

INSERT INTO tbi_bitacora VALUES
    (DEFAULT,
    current_user(), 
    'Delete', 
    'tbd_usuarios_roles', 
    CONCAT_WS(' ','Se ha eliminado un rol de usuario: ',v_nombre_rol, ' al usuario con correo electrónico:', v_email_usuario, '.'),
    DEFAULT, DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbi_bitacora`
--

DROP TABLE IF EXISTS `tbi_bitacora`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbi_bitacora` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Usuario` varchar(50) NOT NULL,
  `Operacion` enum('Create','Read','Update','Delete') NOT NULL,
  `Tabla` varchar(50) NOT NULL,
  `Descripcion` text NOT NULL,
  `Estatus` bit(1) DEFAULT b'1',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=564 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbi_bitacora`
--

LOCK TABLES `tbi_bitacora` WRITE;
/*!40000 ALTER TABLE `tbi_bitacora` DISABLE KEYS */;
INSERT INTO `tbi_bitacora` VALUES (1,'jose.gomez@%','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID:  1 \n Nombre:  Alejandro Barrera Fernández \n Titulo:  Dr. \n Primer Apellido:  Barrera \n Segundo Apellido:  Fernández \n CURP:  BAFA810525HVZLRR05 \n Genero:  M \n Grupo Sanguineo:  O+ \n Fecha de Nacimiento:  1981-05-25 \n Estatus:  Activo',_binary '','2024-07-18 11:15:05'),(2,'jonathan.ibarra@%','Create','tbb_personal_medico','Se ha creado nuevo personal medico con los siguientes datos: \n Nombre de la Persona:  Alejandro   Barrera   Fernández \n Nombre del Departamento:  División de Pediatría \n Especialidad:  Pediatría \n Tipo:  Médico \n Cedula Profesional:  25515487 \n Estatus:  Activo \n Fecha de Contratación:  2015-09-16 09:10:52 \n Salario:  35000.00 \n Fecha de Actualización:  \n',_binary '','2024-07-18 11:15:05'),(3,'jose.gomez@%','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID:  2 \n Nombre:  María José Álvarez Fonseca \n Titulo:  Dra. \n Primer Apellido:  Álvarez \n Segundo Apellido:  Fonseca \n CURP:  ALFM900620MPLLNR2A \n Genero:  F \n Grupo Sanguineo:  O- \n Fecha de Nacimiento:  1990-06-20 \n Estatus:  Activo',_binary '','2024-07-18 11:15:05'),(4,'jonathan.ibarra@%','Create','tbb_personal_medico','Se ha creado nuevo personal medico con los siguientes datos: \n Nombre de la Persona:  María José   Álvarez   Fonseca \n Nombre del Departamento:  División de Medicina Interna \n Especialidad:  \n Tipo:  Médico \n Cedula Profesional:  11422587 \n Estatus:  Activo \n Fecha de Contratación:  2018-05-10 09:10:52 \n Salario:  10000.00 \n Fecha de Actualización:  \n',_binary '','2024-07-18 11:15:05'),(5,'jose.gomez@%','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID:  3 \n Nombre:  Alfredo Carrasco Lechuga \n Titulo:  Dr. \n Primer Apellido:  Carrasco \n Segundo Apellido:  Lechuga \n CURP:  CALA710115HCSRCL25 \n Genero:  M \n Grupo Sanguineo:  AB- \n Fecha de Nacimiento:  1971-01-15 \n Estatus:  Activo',_binary '','2024-07-18 11:15:05'),(6,'jonathan.ibarra@%','Create','tbb_personal_medico','Se ha creado nuevo personal medico con los siguientes datos: \n Nombre de la Persona:  Alfredo   Carrasco   Lechuga \n Nombre del Departamento:  Dirección General \n Especialidad:  \n Tipo:  Administrativo \n Cedula Profesional:  3256884 \n Estatus:  Activo \n Fecha de Contratación:  2000-01-02 09:00:00 \n Salario:  40000.00 \n Fecha de Actualización:  \n',_binary '','2024-07-18 11:15:05'),(7,'jose.gomez@%','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID:  4 \n Nombre:  Fernanda García Méndez \n Titulo:  Lic. \n Primer Apellido:  García \n Segundo Apellido:  Méndez \n CURP:  ABCD \n Genero:  N/B \n Grupo Sanguineo:  A+ \n Fecha de Nacimiento:  1995-05-10 \n Estatus:  Activo',_binary '','2024-07-18 11:15:05'),(8,'jonathan.ibarra@%','Create','tbb_personal_medico','Se ha creado nuevo personal medico con los siguientes datos: \n Nombre de la Persona:  Fernanda   García   Méndez \n Nombre del Departamento:  Seguridad del Paciente \n Especialidad:  \n Tipo:  Apoyo \n Cedula Profesional:  1458817 \n Estatus:  Activo \n Fecha de Contratación:  2008-01-02 19:00:00 \n Salario:  8000.00 \n Fecha de Actualización:  \n',_binary '','2024-07-18 11:15:05'),(9,'jonathan.ibarra@%','Update','tbb_personal_medico','Se ha modificado el personal médico con los siguientes datos: \n Nombre de la Persona:  Alfredo   Carrasco   Lechuga  ->  Alfredo   Carrasco   Lechuga \n Nombre del Departamento:  Dirección General  ->  Dirección General \n Especialidad:   ->  \n Tipo:  Administrativo  ->  Administrativo \n Cédula Profesional:  3256884  ->  3256884 \n Estatus:  Activo  ->  Activo \n Fecha de Contratación:  2000-01-02 09:00:00  ->  2000-01-02 09:00:00 \n Salario:  40000.00  ->  45000.00 \n',_binary '','2024-07-18 11:15:05'),(10,'jonathan.ibarra@%','Delete','tbb_personal_medico','Se ha eliminado personal médico existente con los siguientes datos: \nNombre de la Persona:  Fernanda   García   Méndez \nNombre del Departamento:  Seguridad del Paciente \nEspecialidad:  \nTipo:  Apoyo Cédula Profesional:  1458817 \nEstatus:  Activo \nFecha de Contratación:  2008-01-02 19:00:00 \nSalario:  8000.00',_binary '','2024-07-18 11:15:05'),(11,'jose.gomez@%','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID:  5 \n Nombre:  María López Martínez \n Titulo:  Sra. \n Primer Apellido:  López \n Segundo Apellido:  Martínez \n CURP:  LOMJ850202MDFRPL01 \n Genero:  F \n Grupo Sanguineo:  A+ \n Fecha de Nacimiento:  1985-02-02 \n Estatus:  Activo',_binary '','2024-07-18 11:15:06'),(12,'justin.muñoz@%','Create','tbb_pacientes','Se ha creado un nuevo paciente con los siguientes datos: \n NSS:  \n TIPO SEGURO:  Sin Seguro \n ESTATUS MEDICO:  Normal \n ESTATUS VIDA:  Vivo \n ESTATUS:  Activo \n',_binary '','2024-07-18 11:15:06'),(13,'jose.gomez@%','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID:  6 \n Nombre:  Ana Hernández Ruiz \n Titulo:  \n Primer Apellido:  Hernández \n Segundo Apellido:  Ruiz \n CURP:  HERA900303HDFRRL01 \n Genero:  F \n Grupo Sanguineo:  B+ \n Fecha de Nacimiento:  1990-03-03 \n Estatus:  Activo',_binary '','2024-07-18 11:15:06'),(14,'justin.muñoz@%','Create','tbb_pacientes','Se ha creado un nuevo paciente con los siguientes datos: \n NSS:  \n TIPO SEGURO:  Sin Seguro \n ESTATUS MEDICO:  Normal \n ESTATUS VIDA:  Vivo \n ESTATUS:  Activo \n',_binary '','2024-07-18 11:15:06'),(15,'jose.gomez@%','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID:  7 \n Nombre:  Carlos García Rodríguez \n Titulo:  Dr. \n Primer Apellido:  García \n Segundo Apellido:  Rodríguez \n CURP:  GARC950404HDFRRL06 \n Genero:  M \n Grupo Sanguineo:  AB+ \n Fecha de Nacimiento:  1995-04-04 \n Estatus:  Activo',_binary '','2024-07-18 11:15:06'),(16,'justin.muñoz@%','Create','tbb_pacientes','Se ha creado un nuevo paciente con los siguientes datos: \n NSS:  G9OA6QW29V8DVXS \n TIPO SEGURO:  Seguro Popular \n ESTATUS MEDICO:  Normal \n ESTATUS VIDA:  Vivo \n ESTATUS:  Activo \n',_binary '','2024-07-18 11:15:06'),(17,'jose.gomez@%','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID:  8 \n Nombre:  Laura Martínez Gómez \n Titulo:  Lic. \n Primer Apellido:  Martínez \n Segundo Apellido:  Gómez \n CURP:  MALG000505MDFRRL07 \n Genero:  F \n Grupo Sanguineo:  O- \n Fecha de Nacimiento:  2000-05-05 \n Estatus:  Activo',_binary '','2024-07-18 11:15:06'),(18,'justin.muñoz@%','Create','tbb_pacientes','Se ha creado un nuevo paciente con los siguientes datos: \n NSS:  12254185844-3 \n TIPO SEGURO:  Particular \n ESTATUS MEDICO:  Normal \n ESTATUS VIDA:  Vivo \n ESTATUS:  Activo \n',_binary '','2024-07-18 11:15:06'),(19,'justin.muñoz@%','Update','tbb_pacientes','Se ha creado un modificado al paciente con NSS:  G9OA6QW29V8DVXS con los siguientes datos: \n NSS:  G9OA6QW29V8DVXS  ->  JL4HVKXPI3PX999 \n TIPO SEGURO:  Seguro Popular  ->  Seguro Popular \n ESTATUS MEDICO:  Normal  ->  Normal \n ESTATUS VIDA:  Vivo  ->  Vivo \n ESTATUS:  Activo -> Activo \n',_binary '','2024-07-18 11:15:06'),(20,'justin.muñoz@%','Delete','tbb_pacientes','Se ha eliminado un paciente existente con NSS:  JL4HVKXPI3PX999 y con los siguientes datos: \n TIPO SEGURO:  Seguro Popular \n ESTATUS MEDICO:  Normal \n ESTATUS VIDA:  Vivo \nESTATUS:  Activo \n',_binary '','2024-07-18 11:15:06'),(21,'alexis.gomez@%','Create','tbc_servicios_medicos','Se ha registrado un nuevo servicio médico con los siguientes datos: \n NOMBRE: Consulta Médica General \n DESCRIPCION: Revisión general del paciente por parte de un médico autorizado \n OBSERVACIONES: Horario de Atención de 08:00 a 20:00 \n FECHA REGISTRO: 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: \n',_binary '','2024-07-18 11:15:07'),(22,'alexis.gomez@%','Create','tbd_departamentos_servicios','Se ha registrado un nuevo departamento-servicio con los siguientes datos: \n Departamento: Servicio de Urgencias Adultos \n Servicio Médico: Consulta Médica General \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Activo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(23,'alexis.gomez@%','Create','tbd_departamentos_servicios','Se ha registrado un nuevo departamento-servicio con los siguientes datos: \n Departamento: Consulta Externa \n Servicio Médico: Consulta Médica General \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Activo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(24,'alexis.gomez@%','Create','tbc_servicios_medicos','Se ha registrado un nuevo servicio médico con los siguientes datos: \n NOMBRE: Consulta Médica Especializada \n DESCRIPCION: Revisión médica de especialidad \n OBSERVACIONES: Previa cita, asignada despúes de una revisión general \n FECHA REGISTRO: 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: \n',_binary '','2024-07-18 11:15:07'),(25,'alexis.gomez@%','Create','tbd_departamentos_servicios','Se ha registrado un nuevo departamento-servicio con los siguientes datos: \n Departamento: Programación Quirúrgica \n Servicio Médico: Consulta Médica Especializada \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Activo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(26,'alexis.gomez@%','Create','tbd_departamentos_servicios','Se ha registrado un nuevo departamento-servicio con los siguientes datos: \n Departamento: División de Medicina Interna \n Servicio Médico: Consulta Médica Especializada \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Activo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(27,'alexis.gomez@%','Create','tbd_departamentos_servicios','Se ha registrado un nuevo departamento-servicio con los siguientes datos: \n Departamento: Terapia Intermedia \n Servicio Médico: Consulta Médica Especializada \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Activo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(28,'alexis.gomez@%','Create','tbd_departamentos_servicios','Se ha registrado un nuevo departamento-servicio con los siguientes datos: \n Departamento: División de Pediatría \n Servicio Médico: Consulta Médica Especializada \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Activo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(29,'alexis.gomez@%','Create','tbd_departamentos_servicios','Se ha registrado un nuevo departamento-servicio con los siguientes datos: \n Departamento: Servicio de Urgencias Pediátricas \n Servicio Médico: Consulta Médica Especializada \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Activo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(30,'alexis.gomez@%','Create','tbd_departamentos_servicios','Se ha registrado un nuevo departamento-servicio con los siguientes datos: \n Departamento: Servicio de Traumatología \n Servicio Médico: Consulta Médica Especializada \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Activo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(31,'alexis.gomez@%','Create','tbc_servicios_medicos','Se ha registrado un nuevo servicio médico con los siguientes datos: \n NOMBRE: Consulta Médica a Domicilio \n DESCRIPCION: Revision médica en el domicilio del paciente \n OBSERVACIONES: Solo para casos de extrema urgencia \n FECHA REGISTRO: 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: \n',_binary '','2024-07-18 11:15:07'),(32,'alexis.gomez@%','Create','tbc_servicios_medicos','Se ha registrado un nuevo servicio médico con los siguientes datos: \n NOMBRE: Examen Físico Completo \n DESCRIPCION: Examen detallado de salud física del paciente \n OBSERVACIONES: Asistir con ropa lijera y 6 a 8 de horas\n        de ayuno previo \n FECHA REGISTRO: 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: \n',_binary '','2024-07-18 11:15:07'),(33,'alexis.gomez@%','Create','tbc_servicios_medicos','Se ha registrado un nuevo servicio médico con los siguientes datos: \n NOMBRE: Extracción de Sangre \n DESCRIPCION: Toma de muestra para análisis de sangre \n OBSERVACIONES: Ayuno previo, muestras antes de las 10:00 a.m. \n FECHA REGISTRO: 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: \n',_binary '','2024-07-18 11:15:07'),(34,'alexis.gomez@%','Create','tbc_servicios_medicos','Se ha registrado un nuevo servicio médico con los siguientes datos: \n NOMBRE: Parto Natural \n DESCRIPCION: Asistencia en el proceso de alumbramiento de un bebé \n OBSERVACIONES: Sin observaciones \n FECHA REGISTRO: 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: \n',_binary '','2024-07-18 11:15:07'),(35,'alexis.gomez@%','Create','tbd_departamentos_servicios','Se ha registrado un nuevo departamento-servicio con los siguientes datos: \n Departamento: División de Pediatría \n Servicio Médico: Parto Natural \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Activo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(36,'alexis.gomez@%','Create','tbd_departamentos_servicios','Se ha registrado un nuevo departamento-servicio con los siguientes datos: \n Departamento: Servicio de Urgencias Pediátricas \n Servicio Médico: Parto Natural \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Activo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(37,'alexis.gomez@%','Create','tbc_servicios_medicos','Se ha registrado un nuevo servicio médico con los siguientes datos: \n NOMBRE: Estudio de Desarrollo Infantil \n DESCRIPCION: Valoración de Crecimiento del Infante \n OBSERVACIONES: Mediciones de Talla, Peso y Nutrición \n FECHA REGISTRO: 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: \n',_binary '','2024-07-18 11:15:07'),(38,'alexis.gomez@%','Create','tbd_departamentos_servicios','Se ha registrado un nuevo departamento-servicio con los siguientes datos: \n Departamento: División de Pediatría \n Servicio Médico: Estudio de Desarrollo Infantil \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Activo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(39,'alexis.gomez@%','Create','tbc_servicios_medicos','Se ha registrado un nuevo servicio médico con los siguientes datos: \n NOMBRE: Toma de Signos Vitales \n DESCRIPCION: Registro de Talla, Peso, Temperatura, Oxigenación en la Sangre , Frecuencia Cardiaca \n        (Sistólica y  Diastólica, Frecuencia Respiratoria \n OBSERVACIONES: Necesarias para cualquier servicio médico. \n FECHA REGISTRO: 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: \n',_binary '','2024-07-18 11:15:07'),(40,'alexis.gomez@%','Create','tbd_departamentos_servicios','Se ha registrado un nuevo departamento-servicio con los siguientes datos: \n Departamento: División de Pediatría \n Servicio Médico: Toma de Signos Vitales \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Activo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(41,'alexis.gomez@%','Create','tbd_departamentos_servicios','Se ha registrado un nuevo departamento-servicio con los siguientes datos: \n Departamento: Servicio de Urgencias Pediátricas \n Servicio Médico: Toma de Signos Vitales \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Activo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(42,'alexis.gomez@%','Create','tbd_departamentos_servicios','Se ha registrado un nuevo departamento-servicio con los siguientes datos: \n Departamento: Terapia Intermedia \n Servicio Médico: Toma de Signos Vitales \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Activo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(43,'alexis.gomez@%','Create','tbd_departamentos_servicios','Se ha registrado un nuevo departamento-servicio con los siguientes datos: \n Departamento: Hemodialisis \n Servicio Médico: Toma de Signos Vitales \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Activo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(44,'alexis.gomez@%','Create','tbd_departamentos_servicios','Se ha registrado un nuevo departamento-servicio con los siguientes datos: \n Departamento: Laboratorio de Análisis Clínicos \n Servicio Médico: Toma de Signos Vitales \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Activo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(45,'alexis.gomez@%','Delete','tbd_departamentos_servicios','Se ha eliminado un departamento-servicio con los siguientes datos: \n Departamento: Hemodialisis \n Servicio Médico: Toma de Signos Vitales \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Inactivo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-07-18 11:15:07'),(46,'alexis.gomez@%','Update','tbd_departamentos_servicios','Se ha modificado un departamento-servicio con los siguientes datos: \n Departamento (antes): Laboratorio de Análisis Clínicos  ->  Laboratorio de Análisis Clínicos \n Servicio Médico (antes): Toma de Signos Vitales  ->  Toma de Signos Vitales \n Requisitos (antes): Ayuno previo de 1 hr.  ->  Ayuno previo de 1 hr. \n Restricciones (antes): Sin restricciones  ->  Sin restricciones \n Estatus (antes): activo  ->  activo \n Fecha_Registro (antes): 2024-07-18 11:15:07  ->  2024-07-18 11:15:07 \n Fecha_Actualizacion:  ->  2024-07-18 11:15:07 \n',_binary '','2024-07-18 11:15:07'),(47,'alexis.gomez@%','Update','tbc_servicios_medicos','Se ha modificado un servicio médico con los siguientes datos: \n NOMBRE: Extracción de Sangre - Estudio de Química Sanguínea \n DESCRIPCION: Toma de muestra para análisis de sangre - Toma de muestra para análisis de sangre \n OBSERVACIONES: Ayuno previo, muestras antes de las 10:00 a.m. - Ayuno previo, muestras antes de las 10:00 a.m. \n FECHA REGISTRO: 2024-07-18 11:15:07 - 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: - 2024-07-18 11:15:07 \n',_binary '','2024-07-18 11:15:07'),(48,'alexis.gomez@%','Delete','tbc_servicios_medicos','Se ha eliminado un servicio médico con los siguientes datos: \n NOMBRE: Consulta Médica a Domicilio \n DESCRIPCION: Revision médica en el domicilio del paciente \n OBSERVACIONES: Solo para casos de extrema urgencia \n FECHA REGISTRO: 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: \n',_binary '','2024-07-18 11:15:07'),(49,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: Medicina General\nTipo: Edificio\nDepartamento: Dirección General\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Ninguno',_binary '','2024-07-18 11:15:08'),(50,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: Planta Baja\nTipo: Piso\nDepartamento: Recursos Materiales\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Medicina General',_binary '','2024-07-18 11:15:08'),(51,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A-101\nTipo: Consultorio\nDepartamento: División de Medicina Interna\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Baja',_binary '','2024-07-18 11:15:08'),(52,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A-102\nTipo: Consultorio\nDepartamento: División de Medicina Interna\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Baja',_binary '','2024-07-18 11:15:08'),(53,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A-103\nTipo: Consultorio\nDepartamento: División de Medicina Interna\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Baja',_binary '','2024-07-18 11:15:08'),(54,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A-104\nTipo: Consultorio\nDepartamento: Servicio de Urgencias Adultos\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Baja',_binary '','2024-07-18 11:15:08'),(55,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A-105\nTipo: Consultorio\nDepartamento: Servicio de Urgencias Adultos\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Baja',_binary '','2024-07-18 11:15:08'),(56,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A-106\nTipo: Quirófano\nDepartamento: División de Cirugía\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Baja',_binary '','2024-07-18 11:15:08'),(57,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A-107\nTipo: Quirófano\nDepartamento: División de Cirugía\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Baja',_binary '','2024-07-18 11:15:08'),(58,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A-108\nTipo: Sala de Espera\nDepartamento: División de Cirugía\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Baja',_binary '','2024-07-18 11:15:08'),(59,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A-109\nTipo: Sala de Espera\nDepartamento: División de Cirugía\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Baja',_binary '','2024-07-18 11:15:08'),(60,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: Planta Alta\nTipo: Piso\nDepartamento: Recursos Materiales\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Medicina General',_binary '','2024-07-18 11:15:08'),(61,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A-201\nTipo: Habitación\nDepartamento: División de Medicina Interna\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Alta',_binary '','2024-07-18 11:15:08'),(62,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A-202\nTipo: Habitación\nDepartamento: División de Medicina Interna\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Alta',_binary '','2024-07-18 11:15:08'),(63,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A-203\nTipo: Habitación\nDepartamento: División de Medicina Interna\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Alta',_binary '','2024-07-18 11:15:08'),(64,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A-204\nTipo: Habitación\nDepartamento: División de Medicina Interna\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Alta',_binary '','2024-07-18 11:15:08'),(65,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A-205\nTipo: Habitación\nDepartamento: División de Medicina Interna\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Alta',_binary '','2024-07-18 11:15:08'),(66,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A206\nTipo: Laboratorio\nDepartamento: Laboratorio de Análisis Clínicos\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Alta',_binary '','2024-07-18 11:15:08'),(67,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A-207\nTipo: Capilla\nDepartamento: Recursos Materiales\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Alta',_binary '','2024-07-18 11:15:08'),(68,'bruno.lemus@%','Create','tbc_espacios','Se ha agregado un nuevo ESPACIO con el Nombre: A-208\nTipo: Recepción\nDepartamento: Dirección General\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Alta',_binary '','2024-07-18 11:15:08'),(69,'bruno.lemus@%','Update','tbc_espacios','Se ha actualizado un ESPACIO con el Nombre: A-105\nTipo: Consultorio\nDepartamento: Servicio de Urgencias Adultos\nEstatus: En remodelación\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: 2024-07-18 11:15:08\nCapacidad: 0\nEspacio Superior: Planta Baja',_binary '','2024-07-18 11:15:08'),(70,'bruno.lemus@%','Update','tbc_espacios','Se ha actualizado un ESPACIO con el Nombre: A-109\nTipo: Sala de Espera\nDepartamento: División de Cirugía\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: 2024-07-18 11:15:08\nCapacidad: 80\nEspacio Superior: Planta Baja',_binary '','2024-07-18 11:15:08'),(71,'bruno.lemus@%','Delete','tbc_espacios','Se ha eliminado un ESPACIO con el Nombre: A-207\nTipo: Capilla\nDepartamento: Recursos Materiales\nEstatus: Activo\nFecha de Registro: 2024-07-18 11:15:08\nFecha de Actualización: NULL\nCapacidad: 0\nEspacio Superior: Planta Alta',_binary '','2024-07-18 11:15:08'),(72,'Cristian.Ojeda@%','Create','tbc_medicamentos','Se ha insertado un nuevo medicamento con ID: 1 \n Nombre Comercial: Tylenol \n Nombre Genérico: Paracetamol \n Vía de Administración: Oral \n Presentación: Comprimidos \n Tipo: Analgesicos \n Cantidad: 100 \n Volumen: 0.00',_binary '','2024-08-22 10:28:39'),(73,'Cristian.Ojeda@%','Create','tbc_medicamentos','Se ha insertado un nuevo medicamento con ID: 2 \n Nombre Comercial: Amoxil \n Nombre Genérico: Amoxicilina \n Vía de Administración: Oral \n Presentación: Capsulas \n Tipo: Antibioticos \n Cantidad: 50 \n Volumen: 0.00',_binary '','2024-08-22 10:28:39'),(74,'Cristian.Ojeda@%','Create','tbc_medicamentos','Se ha insertado un nuevo medicamento con ID: 3 \n Nombre Comercial: Zoloft \n Nombre Genérico: Sertralina \n Vía de Administración: Oral \n Presentación: Comprimidos \n Tipo: Antidepresivos \n Cantidad: 200 \n Volumen: 0.00',_binary '','2024-08-22 10:28:39'),(75,'Cristian.Ojeda@%','Create','tbc_medicamentos','Se ha insertado un nuevo medicamento con ID: 4 \n Nombre Comercial: Claritin \n Nombre Genérico: Loratadina \n Vía de Administración: Oral \n Presentación: Grageas \n Tipo: Antihistaminicos \n Cantidad: 150 \n Volumen: 0.00',_binary '','2024-08-22 10:28:39'),(76,'Cristian.Ojeda@%','Create','tbc_medicamentos','Se ha insertado un nuevo medicamento con ID: 5 \n Nombre Comercial: Advil \n Nombre Genérico: Ibuprofeno \n Vía de Administración: Oral \n Presentación: Comprimidos \n Tipo: Antiinflamatorios \n Cantidad: 300 \n Volumen: 0.00',_binary '','2024-08-22 10:28:39'),(77,'Cristian.Ojeda@%','Update','tbc_medicamentos','Se ha actualizado el medicamento con ID: 1 \n Nombre Comercial: Tylenol - Tylenol \n Nombre Genérico: Paracetamol - Paracetamol \n Vía de Administración: Oral - Oral \n Presentación: Comprimidos - Comprimidos \n Tipo: Analgesicos - Analgesicos \n Cantidad: 100 - 120 \n Volumen: 0.00 - 10.00',_binary '','2024-08-22 10:28:39'),(78,'Cristian.Ojeda@%','Delete','tbc_medicamentos','Se ha eliminado el medicamento con ID: 2 \n Nombre Comercial: Amoxil \n Nombre Genérico: Amoxicilina',_binary '','2024-08-22 10:28:39'),(79,'alexis.gomez@%','Delete','tbd_departamentos_servicios','Se ha eliminado un departamento-servicio con los siguientes datos: \n Departamento: Programación Quirúrgica \n Servicio Médico: Consulta Médica Especializada \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Inactivo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-08-22 10:31:48'),(80,'alexis.gomez@%','Delete','tbd_departamentos_servicios','Se ha eliminado un departamento-servicio con los siguientes datos: \n Departamento: División de Medicina Interna \n Servicio Médico: Consulta Médica Especializada \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Inactivo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-08-22 10:31:48'),(81,'alexis.gomez@%','Delete','tbd_departamentos_servicios','Se ha eliminado un departamento-servicio con los siguientes datos: \n Departamento: Terapia Intermedia \n Servicio Médico: Consulta Médica Especializada \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Inactivo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-08-22 10:31:48'),(82,'alexis.gomez@%','Delete','tbd_departamentos_servicios','Se ha eliminado un departamento-servicio con los siguientes datos: \n Departamento: Terapia Intermedia \n Servicio Médico: Toma de Signos Vitales \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Inactivo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-08-22 10:31:48'),(83,'alexis.gomez@%','Delete','tbd_departamentos_servicios','Se ha eliminado un departamento-servicio con los siguientes datos: \n Departamento: División de Pediatría \n Servicio Médico: Consulta Médica Especializada \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Inactivo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-08-22 10:31:48'),(84,'alexis.gomez@%','Delete','tbd_departamentos_servicios','Se ha eliminado un departamento-servicio con los siguientes datos: \n Departamento: División de Pediatría \n Servicio Médico: Parto Natural \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Inactivo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-08-22 10:31:48'),(85,'alexis.gomez@%','Delete','tbd_departamentos_servicios','Se ha eliminado un departamento-servicio con los siguientes datos: \n Departamento: División de Pediatría \n Servicio Médico: Estudio de Desarrollo Infantil \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Inactivo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-08-22 10:31:48'),(86,'alexis.gomez@%','Delete','tbd_departamentos_servicios','Se ha eliminado un departamento-servicio con los siguientes datos: \n Departamento: División de Pediatría \n Servicio Médico: Toma de Signos Vitales \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Inactivo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-08-22 10:31:48'),(87,'alexis.gomez@%','Delete','tbd_departamentos_servicios','Se ha eliminado un departamento-servicio con los siguientes datos: \n Departamento: Servicio de Urgencias Pediátricas \n Servicio Médico: Consulta Médica Especializada \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Inactivo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-08-22 10:31:48'),(88,'alexis.gomez@%','Delete','tbd_departamentos_servicios','Se ha eliminado un departamento-servicio con los siguientes datos: \n Departamento: Servicio de Urgencias Pediátricas \n Servicio Médico: Parto Natural \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Inactivo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-08-22 10:31:48'),(89,'alexis.gomez@%','Delete','tbd_departamentos_servicios','Se ha eliminado un departamento-servicio con los siguientes datos: \n Departamento: Servicio de Urgencias Pediátricas \n Servicio Médico: Toma de Signos Vitales \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Inactivo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-08-22 10:31:48'),(90,'alexis.gomez@%','Delete','tbd_departamentos_servicios','Se ha eliminado un departamento-servicio con los siguientes datos: \n Departamento: Servicio de Traumatología \n Servicio Médico: Consulta Médica Especializada \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Inactivo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-08-22 10:31:48'),(91,'alexis.gomez@%','Delete','tbd_departamentos_servicios','Se ha eliminado un departamento-servicio con los siguientes datos: \n Departamento: Servicio de Urgencias Adultos \n Servicio Médico: Consulta Médica General \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Inactivo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-08-22 10:31:48'),(92,'alexis.gomez@%','Delete','tbd_departamentos_servicios','Se ha eliminado un departamento-servicio con los siguientes datos: \n Departamento: Laboratorio de Análisis Clínicos \n Servicio Médico: Toma de Signos Vitales \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Inactivo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: 2024-07-18 11:15:07 \n',_binary '','2024-08-22 10:31:48'),(93,'alexis.gomez@%','Delete','tbd_departamentos_servicios','Se ha eliminado un departamento-servicio con los siguientes datos: \n Departamento: Consulta Externa \n Servicio Médico: Consulta Médica General \n Requisitos: Ayuno previo de 1 hr. \n Restricciones: Sin restricciones \n Estatus: Inactivo \n Fecha_Registro: 2024-07-18 11:15:07 \n Fecha_Actualizacion: \n',_binary '','2024-08-22 10:31:48'),(94,'alexis.gomez@%','Delete','tbc_servicios_medicos','Se ha eliminado un servicio médico con los siguientes datos: \n NOMBRE: Consulta Médica General \n DESCRIPCION: Revisión general del paciente por parte de un médico autorizado \n OBSERVACIONES: Horario de Atención de 08:00 a 20:00 \n FECHA REGISTRO: 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: \n',_binary '','2024-08-22 10:32:12'),(95,'alexis.gomez@%','Delete','tbc_servicios_medicos','Se ha eliminado un servicio médico con los siguientes datos: \n NOMBRE: Consulta Médica Especializada \n DESCRIPCION: Revisión médica de especialidad \n OBSERVACIONES: Previa cita, asignada despúes de una revisión general \n FECHA REGISTRO: 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: \n',_binary '','2024-08-22 10:32:12'),(96,'alexis.gomez@%','Delete','tbc_servicios_medicos','Se ha eliminado un servicio médico con los siguientes datos: \n NOMBRE: Examen Físico Completo \n DESCRIPCION: Examen detallado de salud física del paciente \n OBSERVACIONES: Asistir con ropa lijera y 6 a 8 de horas\n        de ayuno previo \n FECHA REGISTRO: 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: \n',_binary '','2024-08-22 10:32:12'),(97,'alexis.gomez@%','Delete','tbc_servicios_medicos','Se ha eliminado un servicio médico con los siguientes datos: \n NOMBRE: Estudio de Química Sanguínea \n DESCRIPCION: Toma de muestra para análisis de sangre \n OBSERVACIONES: Ayuno previo, muestras antes de las 10:00 a.m. \n FECHA REGISTRO: 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: 2024-07-18 11:15:07 \n',_binary '','2024-08-22 10:32:12'),(98,'alexis.gomez@%','Delete','tbc_servicios_medicos','Se ha eliminado un servicio médico con los siguientes datos: \n NOMBRE: Parto Natural \n DESCRIPCION: Asistencia en el proceso de alumbramiento de un bebé \n OBSERVACIONES: Sin observaciones \n FECHA REGISTRO: 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: \n',_binary '','2024-08-22 10:32:12'),(99,'alexis.gomez@%','Delete','tbc_servicios_medicos','Se ha eliminado un servicio médico con los siguientes datos: \n NOMBRE: Estudio de Desarrollo Infantil \n DESCRIPCION: Valoración de Crecimiento del Infante \n OBSERVACIONES: Mediciones de Talla, Peso y Nutrición \n FECHA REGISTRO: 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: \n',_binary '','2024-08-22 10:32:12'),(100,'alexis.gomez@%','Delete','tbc_servicios_medicos','Se ha eliminado un servicio médico con los siguientes datos: \n NOMBRE: Toma de Signos Vitales \n DESCRIPCION: Registro de Talla, Peso, Temperatura, Oxigenación en la Sangre , Frecuencia Cardiaca \n        (Sistólica y  Diastólica, Frecuencia Respiratoria \n OBSERVACIONES: Necesarias para cualquier servicio médico. \n FECHA REGISTRO: 2024-07-18 11:15:07 \n FECHA ACTUALIZACION: \n',_binary '','2024-08-22 10:32:12'),(101,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  1 \n Para el paciente con id: 1',_binary '','2024-08-22 10:45:20'),(102,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  2 \n Para el paciente con id: 2',_binary '','2024-08-22 10:45:37'),(103,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  3 \n Para el paciente con id: 3',_binary '','2024-08-22 10:45:37'),(104,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  4 \n Para el paciente con id: 4',_binary '','2024-08-22 10:45:37'),(105,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  5 \n Para el paciente con id: 5',_binary '','2024-08-22 10:45:37'),(106,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  6 \n Para el paciente con id: 6',_binary '','2024-08-22 10:45:37'),(107,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  7 \n Para el paciente con id: 7',_binary '','2024-08-22 10:45:37'),(108,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  8 \n Para el paciente con id: 8',_binary '','2024-08-22 10:45:37'),(109,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  9 \n Para el paciente con id: 9',_binary '','2024-08-22 10:45:37'),(110,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  10 \n Para el paciente con id: 10',_binary '','2024-08-22 10:45:37'),(111,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  11 \n Para el paciente con id: 11',_binary '','2024-08-22 10:45:37'),(112,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  12 \n Para el paciente con id: 12',_binary '','2024-08-22 10:45:37'),(113,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  13 \n Para el paciente con id: 13',_binary '','2024-08-22 10:45:37'),(114,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  14 \n Para el paciente con id: 14',_binary '','2024-08-22 10:45:37'),(115,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  15 \n Para el paciente con id: 15',_binary '','2024-08-22 10:45:37'),(116,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  16 \n Para el paciente con id: 16',_binary '','2024-08-22 10:45:37'),(117,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  17 \n Para el paciente con id: 17',_binary '','2024-08-22 10:45:37'),(118,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 1',_binary '','2024-08-22 10:48:19'),(119,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 2',_binary '','2024-08-22 10:48:19'),(120,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 3',_binary '','2024-08-22 10:48:19'),(121,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 4',_binary '','2024-08-22 10:48:19'),(122,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 5',_binary '','2024-08-22 10:48:19'),(123,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 6',_binary '','2024-08-22 10:48:19'),(124,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 7',_binary '','2024-08-22 10:48:19'),(125,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 8',_binary '','2024-08-22 10:48:19'),(126,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 9',_binary '','2024-08-22 10:48:19'),(127,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 10',_binary '','2024-08-22 10:48:19'),(128,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 11',_binary '','2024-08-22 10:48:19'),(129,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 12',_binary '','2024-08-22 10:48:19'),(130,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 13',_binary '','2024-08-22 10:48:19'),(131,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 14',_binary '','2024-08-22 10:48:19'),(132,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 15',_binary '','2024-08-22 10:48:19'),(133,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 16',_binary '','2024-08-22 10:48:19'),(134,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 17',_binary '','2024-08-22 10:48:19'),(135,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  1 \n Para el paciente con id: 5',_binary '','2024-08-22 10:48:23'),(136,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 1',_binary '','2024-08-22 10:48:34'),(137,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  1 \n Para el paciente con id: 5',_binary '','2024-08-22 10:48:38'),(138,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 1',_binary '','2024-08-22 10:48:52'),(139,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  1 \n Para el paciente con id: 5',_binary '','2024-08-22 10:49:04'),(140,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  4 \n Para el paciente con id: 6',_binary '','2024-08-22 10:50:54'),(141,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 1',_binary '','2024-08-22 10:56:57'),(142,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta del paciente con id: 4',_binary '','2024-08-22 10:56:57'),(143,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  1 \n Para el paciente con id: 5',_binary '','2024-08-22 10:57:14'),(144,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 1',_binary '','2024-08-22 10:59:04'),(145,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  1 \n Para el paciente con id: 5',_binary '','2024-08-22 10:59:19'),(146,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 1',_binary '','2024-08-22 11:05:08'),(147,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  1 \n Para el paciente con id: 5',_binary '','2024-08-22 11:05:23'),(148,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  3 \n Para el paciente con id: 5',_binary '','2024-08-22 11:07:04'),(149,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  4 \n Para el paciente con id: 5',_binary '','2024-08-22 11:07:04'),(150,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 1',_binary '','2024-08-22 11:07:31'),(151,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 3',_binary '','2024-08-22 11:07:31'),(152,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 4',_binary '','2024-08-22 11:07:31'),(153,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  1 \n Para el paciente con id: 5',_binary '','2024-08-22 11:07:39'),(154,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  2 \n Para el paciente con id: 5',_binary '','2024-08-22 11:07:39'),(155,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  3 \n Para el paciente con id: 5',_binary '','2024-08-22 11:07:39'),(156,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  4 \n Para el paciente con id: 5',_binary '','2024-08-22 11:07:39'),(157,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  5 \n Para el paciente con id: 5',_binary '','2024-08-22 11:07:39'),(158,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  6 \n Para el paciente con id: 5',_binary '','2024-08-22 11:07:39'),(159,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  7 \n Para el paciente con id: 5',_binary '','2024-08-22 11:07:39'),(160,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  8 \n Para el paciente con id: 5',_binary '','2024-08-22 11:07:39'),(161,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  9 \n Para el paciente con id: 5',_binary '','2024-08-22 11:07:39'),(162,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  10 \n Para el paciente con id: 5',_binary '','2024-08-22 11:07:39'),(163,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 1',_binary '','2024-08-22 11:09:12'),(164,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 2',_binary '','2024-08-22 11:09:12'),(165,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 3',_binary '','2024-08-22 11:09:12'),(166,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 4',_binary '','2024-08-22 11:09:12'),(167,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 5',_binary '','2024-08-22 11:09:12'),(168,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 6',_binary '','2024-08-22 11:09:12'),(169,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 7',_binary '','2024-08-22 11:09:12'),(170,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 8',_binary '','2024-08-22 11:09:12'),(171,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 9',_binary '','2024-08-22 11:09:12'),(172,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 10',_binary '','2024-08-22 11:09:12'),(173,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  1 \n Para el paciente con id: 5',_binary '','2024-08-22 11:10:51'),(174,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  2 \n Para el paciente con id: 5',_binary '','2024-08-22 11:10:51'),(175,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  3 \n Para el paciente con id: 5',_binary '','2024-08-22 11:10:51'),(176,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  4 \n Para el paciente con id: 5',_binary '','2024-08-22 11:10:51'),(177,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  5 \n Para el paciente con id: 5',_binary '','2024-08-22 11:10:51'),(178,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  6 \n Para el paciente con id: 5',_binary '','2024-08-22 11:10:51'),(179,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  7 \n Para el paciente con id: 5',_binary '','2024-08-22 11:10:51'),(180,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  8 \n Para el paciente con id: 5',_binary '','2024-08-22 11:10:51'),(181,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  9 \n Para el paciente con id: 5',_binary '','2024-08-22 11:10:51'),(182,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  10 \n Para el paciente con id: 5',_binary '','2024-08-22 11:10:51'),(183,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 1',_binary '','2024-08-22 11:14:49'),(184,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 2',_binary '','2024-08-22 11:14:49'),(185,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 3',_binary '','2024-08-22 11:14:49'),(186,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 4',_binary '','2024-08-22 11:14:49'),(187,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 5',_binary '','2024-08-22 11:14:49'),(188,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 6',_binary '','2024-08-22 11:14:49'),(189,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 7',_binary '','2024-08-22 11:14:49'),(190,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 8',_binary '','2024-08-22 11:14:49'),(191,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 9',_binary '','2024-08-22 11:14:49'),(192,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 10',_binary '','2024-08-22 11:14:49'),(193,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  1 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:52'),(194,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  2 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:52'),(195,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  3 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:52'),(196,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  4 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:52'),(197,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  5 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:52'),(198,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  6 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:52'),(199,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  7 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:52'),(200,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  8 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:52'),(201,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  9 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:52'),(202,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  10 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:52'),(203,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 1',_binary '','2024-08-22 11:14:52'),(204,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 2',_binary '','2024-08-22 11:14:52'),(205,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 3',_binary '','2024-08-22 11:14:52'),(206,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 4',_binary '','2024-08-22 11:14:52'),(207,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 5',_binary '','2024-08-22 11:14:52'),(208,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 6',_binary '','2024-08-22 11:14:52'),(209,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 7',_binary '','2024-08-22 11:14:52'),(210,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 8',_binary '','2024-08-22 11:14:52'),(211,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 9',_binary '','2024-08-22 11:14:52'),(212,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 10',_binary '','2024-08-22 11:14:52'),(213,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  11 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:59'),(214,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  12 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:59'),(215,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  13 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:59'),(216,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  14 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:59'),(217,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  15 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:59'),(218,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  16 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:59'),(219,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  17 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:59'),(220,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  18 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:59'),(221,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  19 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:59'),(222,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  20 \n Para el paciente con id: 5',_binary '','2024-08-22 11:14:59'),(223,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 11',_binary '','2024-08-22 11:14:59'),(224,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 12',_binary '','2024-08-22 11:14:59'),(225,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 13',_binary '','2024-08-22 11:14:59'),(226,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 14',_binary '','2024-08-22 11:14:59'),(227,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 15',_binary '','2024-08-22 11:14:59'),(228,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 16',_binary '','2024-08-22 11:14:59'),(229,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 17',_binary '','2024-08-22 11:14:59'),(230,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 18',_binary '','2024-08-22 11:14:59'),(231,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 19',_binary '','2024-08-22 11:14:59'),(232,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 20',_binary '','2024-08-22 11:14:59'),(233,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  1 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:20'),(234,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  2 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:20'),(235,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  3 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:20'),(236,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  4 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:20'),(237,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  5 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:20'),(238,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  6 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:20'),(239,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  7 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:20'),(240,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  8 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:20'),(241,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  9 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:20'),(242,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  10 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:20'),(243,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 1',_binary '','2024-08-22 11:15:20'),(244,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 2',_binary '','2024-08-22 11:15:20'),(245,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 3',_binary '','2024-08-22 11:15:20'),(246,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 4',_binary '','2024-08-22 11:15:20'),(247,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 5',_binary '','2024-08-22 11:15:20'),(248,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 6',_binary '','2024-08-22 11:15:20'),(249,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 7',_binary '','2024-08-22 11:15:20'),(250,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 8',_binary '','2024-08-22 11:15:20'),(251,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 9',_binary '','2024-08-22 11:15:20'),(252,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 10',_binary '','2024-08-22 11:15:20'),(253,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  11 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:28'),(254,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  12 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:28'),(255,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  13 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:28'),(256,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  14 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:28'),(257,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  15 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:28'),(258,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  16 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:28'),(259,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  17 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:28'),(260,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  18 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:28'),(261,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  19 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:28'),(262,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  20 \n Para el paciente con id: 5',_binary '','2024-08-22 11:15:28'),(263,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 11',_binary '','2024-08-22 11:15:28'),(264,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 12',_binary '','2024-08-22 11:15:28'),(265,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 13',_binary '','2024-08-22 11:15:28'),(266,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 14',_binary '','2024-08-22 11:15:28'),(267,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 15',_binary '','2024-08-22 11:15:28'),(268,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 16',_binary '','2024-08-22 11:15:28'),(269,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 17',_binary '','2024-08-22 11:15:28'),(270,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 18',_binary '','2024-08-22 11:15:28'),(271,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 19',_binary '','2024-08-22 11:15:28'),(272,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 20',_binary '','2024-08-22 11:15:28'),(273,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  21 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:08'),(274,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  22 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:08'),(275,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  23 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:08'),(276,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  24 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:08'),(277,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  25 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:08'),(278,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  26 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:08'),(279,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  27 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:08'),(280,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  28 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:08'),(281,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  29 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:08'),(282,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  30 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:08'),(283,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 21',_binary '','2024-08-22 11:16:29'),(284,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 22',_binary '','2024-08-22 11:16:29'),(285,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 23',_binary '','2024-08-22 11:16:29'),(286,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 24',_binary '','2024-08-22 11:16:29'),(287,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 25',_binary '','2024-08-22 11:16:29'),(288,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 26',_binary '','2024-08-22 11:16:29'),(289,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 27',_binary '','2024-08-22 11:16:29'),(290,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 28',_binary '','2024-08-22 11:16:29'),(291,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 29',_binary '','2024-08-22 11:16:29'),(292,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 30',_binary '','2024-08-22 11:16:29'),(293,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  1 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:40'),(294,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  2 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:40'),(295,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  3 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:40'),(296,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  4 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:40'),(297,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  5 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:40'),(298,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  6 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:40'),(299,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  7 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:40'),(300,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  8 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:40'),(301,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  9 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:40'),(302,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  10 \n Para el paciente con id: 5',_binary '','2024-08-22 11:16:40'),(303,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 1',_binary '','2024-08-22 11:18:04'),(304,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 2',_binary '','2024-08-22 11:18:04'),(305,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 3',_binary '','2024-08-22 11:18:04'),(306,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 4',_binary '','2024-08-22 11:18:04'),(307,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 5',_binary '','2024-08-22 11:18:04'),(308,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 6',_binary '','2024-08-22 11:18:04'),(309,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 7',_binary '','2024-08-22 11:18:04'),(310,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 8',_binary '','2024-08-22 11:18:04'),(311,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 9',_binary '','2024-08-22 11:18:04'),(312,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 10',_binary '','2024-08-22 11:18:04'),(313,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  2 \n Para el paciente con id: 5',_binary '','2024-08-22 11:18:28'),(314,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  3 \n Para el paciente con id: 5',_binary '','2024-08-22 11:18:28'),(315,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  4 \n Para el paciente con id: 5',_binary '','2024-08-22 11:18:28'),(316,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  5 \n Para el paciente con id: 5',_binary '','2024-08-22 11:18:28'),(317,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  6 \n Para el paciente con id: 5',_binary '','2024-08-22 11:18:28'),(318,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  7 \n Para el paciente con id: 5',_binary '','2024-08-22 11:18:28'),(319,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  8 \n Para el paciente con id: 5',_binary '','2024-08-22 11:18:28'),(320,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  9 \n Para el paciente con id: 5',_binary '','2024-08-22 11:18:28'),(321,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  10 \n Para el paciente con id: 5',_binary '','2024-08-22 11:18:28'),(322,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  11 \n Para el paciente con id: 5',_binary '','2024-08-22 11:18:28'),(323,'marvin.tolentino@%','Update','tbd_recetas_medicas','Se ha actualizado la receta médica con ID:  5 \n Fecha de cita Actual: 2024-10-11 00:00:00 \n Fecha de cita  Actualizado: 2024-10-11 00:00:00 \n Diagnostico Actual: Gastritis \n Diagnostico Actualizado: Viruela del mono \n',_binary '','2024-08-22 11:18:28'),(324,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 2',_binary '','2024-08-22 11:20:08'),(325,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 3',_binary '','2024-08-22 11:20:08'),(326,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 4',_binary '','2024-08-22 11:20:08'),(327,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 5',_binary '','2024-08-22 11:20:08'),(328,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 6',_binary '','2024-08-22 11:20:08'),(329,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 7',_binary '','2024-08-22 11:20:08'),(330,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 8',_binary '','2024-08-22 11:20:08'),(331,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 9',_binary '','2024-08-22 11:20:08'),(332,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 10',_binary '','2024-08-22 11:20:08'),(333,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 11',_binary '','2024-08-22 11:20:08'),(334,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  1 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:12'),(335,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  2 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:12'),(336,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  3 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:12'),(337,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  4 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:12'),(338,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  5 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:12'),(339,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  6 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:12'),(340,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  7 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:12'),(341,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  8 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:12'),(342,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  9 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:12'),(343,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  10 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:12'),(344,'marvin.tolentino@%','Update','tbd_recetas_medicas','Se ha actualizado la receta médica con ID:  7 \n Fecha de cita Actual: 2024-01-03 00:00:00 \n Fecha de cita  Actualizado: 2024-01-03 00:00:00 \n Diagnostico Actual: Gastritis \n Diagnostico Actualizado: Viruela del mono \n',_binary '','2024-08-22 11:20:12'),(345,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  11 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(346,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  12 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(347,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  13 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(348,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  14 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(349,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  15 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(350,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  16 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(351,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  17 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(352,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  18 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(353,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  19 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(354,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  20 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(355,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  21 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(356,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  22 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(357,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  23 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(358,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  24 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(359,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  25 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(360,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  26 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(361,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  27 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(362,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  28 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(363,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  29 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(364,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  30 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(365,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  31 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(366,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  32 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(367,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  33 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(368,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  34 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(369,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  35 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(370,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  36 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(371,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  37 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(372,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  38 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(373,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  39 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(374,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  40 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(375,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  41 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(376,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  42 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(377,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  43 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(378,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  44 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(379,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  45 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(380,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  46 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(381,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  47 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(382,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  48 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(383,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  49 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(384,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  50 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(385,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  51 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(386,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  52 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(387,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  53 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(388,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  54 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(389,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  55 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(390,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  56 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(391,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  57 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(392,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  58 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(393,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  59 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(394,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  60 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(395,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  61 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(396,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  62 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(397,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  63 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(398,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  64 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(399,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  65 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(400,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  66 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(401,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  67 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(402,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  68 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(403,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  69 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(404,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  70 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(405,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  71 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(406,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  72 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(407,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  73 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(408,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  74 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(409,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  75 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(410,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  76 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(411,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  77 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(412,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  78 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(413,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  79 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(414,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  80 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(415,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  81 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(416,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  82 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(417,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  83 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(418,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  84 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(419,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  85 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(420,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  86 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(421,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  87 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(422,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  88 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(423,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  89 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(424,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  90 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(425,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  91 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(426,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  92 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(427,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  93 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(428,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  94 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(429,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  95 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(430,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  96 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(431,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  97 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(432,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  98 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(433,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  99 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(434,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  100 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(435,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  101 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(436,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  102 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(437,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  103 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(438,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  104 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(439,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  105 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(440,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  106 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(441,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  107 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(442,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  108 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(443,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  109 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(444,'marvin.tolentino@%','Create','tbd_recetas_medicas','Se ha creado una nueva receta médica con ID:  110 \n Para el paciente con id: 5',_binary '','2024-08-22 11:20:36'),(445,'marvin.tolentino@%','Update','tbd_recetas_medicas','Se ha actualizado la receta médica con ID:  37 \n Fecha de cita Actual: 2024-10-09 00:00:00 \n Fecha de cita  Actualizado: 2024-10-09 00:00:00 \n Diagnostico Actual: Gastritis \n Diagnostico Actualizado: Viruela del mono \n',_binary '','2024-08-22 11:20:36'),(446,'marvin.tolentino@%','Update','tbd_recetas_medicas','Se ha actualizado la receta médica con ID:  39 \n Fecha de cita Actual: 2024-11-29 00:00:00 \n Fecha de cita  Actualizado: 2024-11-29 00:00:00 \n Diagnostico Actual: Gastritis \n Diagnostico Actualizado: Viruela del mono \n',_binary '','2024-08-22 11:20:36'),(447,'marvin.tolentino@%','Update','tbd_recetas_medicas','Se ha actualizado la receta médica con ID:  41 \n Fecha de cita Actual: 2024-07-03 00:00:00 \n Fecha de cita  Actualizado: 2024-07-03 00:00:00 \n Diagnostico Actual: Gastritis \n Diagnostico Actualizado: Viruela del mono \n',_binary '','2024-08-22 11:20:36'),(448,'marvin.tolentino@%','Update','tbd_recetas_medicas','Se ha actualizado la receta médica con ID:  51 \n Fecha de cita Actual: 2024-12-04 00:00:00 \n Fecha de cita  Actualizado: 2024-12-04 00:00:00 \n Diagnostico Actual: Gastritis \n Diagnostico Actualizado: Viruela del mono \n',_binary '','2024-08-22 11:20:36'),(449,'marvin.tolentino@%','Update','tbd_recetas_medicas','Se ha actualizado la receta médica con ID:  53 \n Fecha de cita Actual: 2024-10-25 00:00:00 \n Fecha de cita  Actualizado: 2024-10-25 00:00:00 \n Diagnostico Actual: Gastritis \n Diagnostico Actualizado: Viruela del mono \n',_binary '','2024-08-22 11:20:36'),(450,'marvin.tolentino@%','Update','tbd_recetas_medicas','Se ha actualizado la receta médica con ID:  64 \n Fecha de cita Actual: 2024-07-24 00:00:00 \n Fecha de cita  Actualizado: 2024-07-24 00:00:00 \n Diagnostico Actual: Gastritis \n Diagnostico Actualizado: Viruela del mono \n',_binary '','2024-08-22 11:20:36'),(451,'marvin.tolentino@%','Update','tbd_recetas_medicas','Se ha actualizado la receta médica con ID:  74 \n Fecha de cita Actual: 2024-07-02 00:00:00 \n Fecha de cita  Actualizado: 2024-07-02 00:00:00 \n Diagnostico Actual: Gastritis \n Diagnostico Actualizado: Viruela del mono \n',_binary '','2024-08-22 11:20:36'),(452,'marvin.tolentino@%','Update','tbd_recetas_medicas','Se ha actualizado la receta médica con ID:  99 \n Fecha de cita Actual: 2024-10-04 00:00:00 \n Fecha de cita  Actualizado: 2024-10-04 00:00:00 \n Diagnostico Actual: Gastritis \n Diagnostico Actualizado: Viruela del mono \n',_binary '','2024-08-22 11:20:36'),(453,'marvin.tolentino@%','Update','tbd_recetas_medicas','Se ha actualizado la receta médica con ID:  110 \n Fecha de cita Actual: 2024-05-04 00:00:00 \n Fecha de cita  Actualizado: 2024-05-04 00:00:00 \n Diagnostico Actual: Gastritis \n Diagnostico Actualizado: Viruela del mono \n',_binary '','2024-08-22 11:20:36'),(454,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 1',_binary '','2024-08-22 11:32:59'),(455,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 2',_binary '','2024-08-22 11:32:59'),(456,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 3',_binary '','2024-08-22 11:32:59'),(457,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 4',_binary '','2024-08-22 11:32:59'),(458,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 5',_binary '','2024-08-22 11:32:59'),(459,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 6',_binary '','2024-08-22 11:32:59'),(460,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 7',_binary '','2024-08-22 11:32:59'),(461,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 8',_binary '','2024-08-22 11:32:59'),(462,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 9',_binary '','2024-08-22 11:32:59'),(463,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 10',_binary '','2024-08-22 11:32:59'),(464,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 11',_binary '','2024-08-22 11:32:59'),(465,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 12',_binary '','2024-08-22 11:32:59'),(466,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 13',_binary '','2024-08-22 11:32:59'),(467,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 14',_binary '','2024-08-22 11:32:59'),(468,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 15',_binary '','2024-08-22 11:32:59'),(469,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 16',_binary '','2024-08-22 11:32:59'),(470,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 17',_binary '','2024-08-22 11:32:59'),(471,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 18',_binary '','2024-08-22 11:32:59'),(472,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 19',_binary '','2024-08-22 11:32:59'),(473,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 20',_binary '','2024-08-22 11:32:59'),(474,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 21',_binary '','2024-08-22 11:32:59'),(475,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 22',_binary '','2024-08-22 11:32:59'),(476,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 23',_binary '','2024-08-22 11:32:59'),(477,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 24',_binary '','2024-08-22 11:32:59'),(478,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 25',_binary '','2024-08-22 11:32:59'),(479,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 26',_binary '','2024-08-22 11:32:59'),(480,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 27',_binary '','2024-08-22 11:32:59'),(481,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 28',_binary '','2024-08-22 11:32:59'),(482,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 29',_binary '','2024-08-22 11:32:59'),(483,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 30',_binary '','2024-08-22 11:32:59'),(484,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 31',_binary '','2024-08-22 11:32:59'),(485,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 32',_binary '','2024-08-22 11:32:59'),(486,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 33',_binary '','2024-08-22 11:32:59'),(487,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 34',_binary '','2024-08-22 11:32:59'),(488,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 35',_binary '','2024-08-22 11:32:59'),(489,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 36',_binary '','2024-08-22 11:32:59'),(490,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 37',_binary '','2024-08-22 11:32:59'),(491,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 38',_binary '','2024-08-22 11:32:59'),(492,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 39',_binary '','2024-08-22 11:32:59'),(493,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 40',_binary '','2024-08-22 11:32:59'),(494,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 41',_binary '','2024-08-22 11:32:59'),(495,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 42',_binary '','2024-08-22 11:32:59'),(496,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 43',_binary '','2024-08-22 11:32:59'),(497,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 44',_binary '','2024-08-22 11:32:59'),(498,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 45',_binary '','2024-08-22 11:32:59'),(499,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 46',_binary '','2024-08-22 11:32:59'),(500,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 47',_binary '','2024-08-22 11:32:59'),(501,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 48',_binary '','2024-08-22 11:32:59'),(502,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 49',_binary '','2024-08-22 11:32:59'),(503,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 50',_binary '','2024-08-22 11:32:59'),(504,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 51',_binary '','2024-08-22 11:32:59'),(505,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 52',_binary '','2024-08-22 11:32:59'),(506,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 53',_binary '','2024-08-22 11:32:59'),(507,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 54',_binary '','2024-08-22 11:32:59'),(508,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 55',_binary '','2024-08-22 11:32:59'),(509,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 56',_binary '','2024-08-22 11:32:59'),(510,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 57',_binary '','2024-08-22 11:32:59'),(511,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 58',_binary '','2024-08-22 11:32:59'),(512,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 59',_binary '','2024-08-22 11:32:59'),(513,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 60',_binary '','2024-08-22 11:32:59'),(514,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 61',_binary '','2024-08-22 11:32:59'),(515,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 62',_binary '','2024-08-22 11:32:59'),(516,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 63',_binary '','2024-08-22 11:32:59'),(517,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 64',_binary '','2024-08-22 11:32:59'),(518,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 65',_binary '','2024-08-22 11:32:59'),(519,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 66',_binary '','2024-08-22 11:32:59'),(520,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 67',_binary '','2024-08-22 11:32:59'),(521,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 68',_binary '','2024-08-22 11:32:59'),(522,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 69',_binary '','2024-08-22 11:32:59'),(523,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 70',_binary '','2024-08-22 11:32:59'),(524,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 71',_binary '','2024-08-22 11:32:59'),(525,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 72',_binary '','2024-08-22 11:32:59'),(526,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 73',_binary '','2024-08-22 11:32:59'),(527,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 74',_binary '','2024-08-22 11:32:59'),(528,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 75',_binary '','2024-08-22 11:32:59'),(529,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 76',_binary '','2024-08-22 11:32:59'),(530,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 77',_binary '','2024-08-22 11:32:59'),(531,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 78',_binary '','2024-08-22 11:32:59'),(532,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 79',_binary '','2024-08-22 11:32:59'),(533,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 80',_binary '','2024-08-22 11:32:59'),(534,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 81',_binary '','2024-08-22 11:32:59'),(535,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 82',_binary '','2024-08-22 11:32:59'),(536,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 83',_binary '','2024-08-22 11:32:59'),(537,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 84',_binary '','2024-08-22 11:32:59'),(538,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 85',_binary '','2024-08-22 11:32:59'),(539,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 86',_binary '','2024-08-22 11:32:59'),(540,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 87',_binary '','2024-08-22 11:32:59'),(541,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 88',_binary '','2024-08-22 11:32:59'),(542,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 89',_binary '','2024-08-22 11:32:59'),(543,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 90',_binary '','2024-08-22 11:32:59'),(544,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 91',_binary '','2024-08-22 11:32:59'),(545,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 92',_binary '','2024-08-22 11:32:59'),(546,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 93',_binary '','2024-08-22 11:32:59'),(547,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 94',_binary '','2024-08-22 11:32:59'),(548,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 95',_binary '','2024-08-22 11:32:59'),(549,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 96',_binary '','2024-08-22 11:32:59'),(550,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 97',_binary '','2024-08-22 11:32:59'),(551,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 98',_binary '','2024-08-22 11:32:59'),(552,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 99',_binary '','2024-08-22 11:32:59'),(553,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 100',_binary '','2024-08-22 11:32:59'),(554,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 101',_binary '','2024-08-22 11:32:59'),(555,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 102',_binary '','2024-08-22 11:32:59'),(556,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 103',_binary '','2024-08-22 11:32:59'),(557,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 104',_binary '','2024-08-22 11:32:59'),(558,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 105',_binary '','2024-08-22 11:32:59'),(559,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 106',_binary '','2024-08-22 11:32:59'),(560,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 107',_binary '','2024-08-22 11:32:59'),(561,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 108',_binary '','2024-08-22 11:32:59'),(562,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 109',_binary '','2024-08-22 11:32:59'),(563,'marvin.tolentino@%','Delete','tbd_recetas_medicas','se ha eliminado la receta con id: 110',_binary '','2024-08-22 11:32:59');
/*!40000 ALTER TABLE `tbi_bitacora` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'hospital_general_9a_idgs2_210540'
--

--
-- Dumping routines for database 'hospital_general_9a_idgs2_210540'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_calcula_edad` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_calcula_edad`(v_fecha_nacimiento DATE) RETURNS int
    DETERMINISTIC
BEGIN
RETURN TIMESTAMPDIFF(YEAR, v_fecha_nacimiento, CURDATE());
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_numero_aleatorio_dispensaciones` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`Cristian.Ojeda`@`%` FUNCTION `fn_numero_aleatorio_dispensaciones`(maximo INT) RETURNS int
    DETERMINISTIC
BEGIN
  DECLARE numeroAleatorio INT;
    
    -- Generar número aleatorio entre 1 y maximo
    SET numeroAleatorio = FLOOR(RAND() * maximo) + 1;

    RETURN numeroAleatorio;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `generar_diagnosticos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `generar_diagnosticos`() RETURNS varchar(255) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE diagnostico VARCHAR(255);
    SET diagnostico = CASE FLOOR(1 + RAND() * 20)
        WHEN 1 THEN 'Gripe'
        WHEN 2 THEN 'Diabetes Tipo 2'
        WHEN 3 THEN 'Hipertensión Arterial'
        WHEN 4 THEN 'Asma'
        WHEN 5 THEN 'Artritis Reumatoide'
        WHEN 6 THEN 'EPOC'
        WHEN 7 THEN 'Insuficiencia Cardíaca'
        WHEN 8 THEN 'Migraña'
        WHEN 9 THEN 'Osteoporosis'
        WHEN 10 THEN 'Anemia'
        WHEN 11 THEN 'Cáncer de Piel'
        WHEN 12 THEN 'Gastritis'
        WHEN 13 THEN 'Bronquitis'
        WHEN 14 THEN 'Depresión'
        WHEN 15 THEN 'Alergia Alimentaria'
        WHEN 16 THEN 'Apnea del Sueño'
        WHEN 17 THEN 'Fibromialgia'
        WHEN 18 THEN 'Síndrome del Intestino Irritable'
        WHEN 19 THEN 'Hipotiroidismo'
        WHEN 20 THEN 'Hepatitis C'
    END;
    RETURN diagnostico;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `generar_indicaciones` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `generar_indicaciones`() RETURNS varchar(255) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE indicacion VARCHAR(255);
    SET indicacion = CASE FLOOR(1 + RAND() * 20)
        WHEN 1 THEN 'Tomar 1 tableta cada 8 horas.'
        WHEN 2 THEN 'Aplicar la pomada dos veces al día.'
        WHEN 3 THEN 'Evitar el consumo de alcohol.'
        WHEN 4 THEN 'No exponer la zona afectada al sol.'
        WHEN 5 THEN 'Realizar ejercicios de respiración diaria.'
        WHEN 6 THEN 'Tomar abundante agua.'
        WHEN 7 THEN 'Acudir a consulta de control en una semana.'
        WHEN 8 THEN 'Evitar el consumo de alimentos grasos.'
        WHEN 9 THEN 'Descansar durante 48 horas.'
        WHEN 10 THEN 'Mantener la herida limpia y seca.'
        WHEN 11 THEN 'Aplicar hielo en la zona afectada.'
        WHEN 12 THEN 'Tomar el medicamento con alimentos.'
        WHEN 13 THEN 'Usar ropa cómoda y ligera.'
        WHEN 14 THEN 'Realizar caminatas de 30 minutos diarias.'
        WHEN 15 THEN 'Evitar el estrés y las situaciones tensas.'
        WHEN 16 THEN 'No saltarse ninguna dosis.'
        WHEN 17 THEN 'Tomar la medicación antes de dormir.'
        WHEN 18 THEN 'Revisar la presión arterial diariamente.'
        WHEN 19 THEN 'Evitar el uso de productos perfumados en la piel.'
        WHEN 20 THEN 'Guardar reposo en cama durante 5 días.'
    END;
    RETURN indicacion;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `generar_indicaciones_medicamentos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `generar_indicaciones_medicamentos`() RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE indicaciones_m TEXT DEFAULT '';
    DECLARE i INT DEFAULT 0;
    DECLARE num_opciones INT DEFAULT 20;
    DECLARE rnd INT;

    -- Generar un número aleatorio entre 1 y 20
    SET rnd = FLOOR(1 + (RAND() * num_opciones));

    -- Seleccionar una indicación basada en el número aleatorio
    SET indicaciones_m = CASE rnd
        WHEN 1 THEN 'Tomar una pastilla con agua después del desayuno.'
        WHEN 2 THEN 'Tomar dos pastillas con agua antes de acostarse.'
        WHEN 3 THEN 'Tomar una pastilla con alimentos durante la comida.'
        WHEN 4 THEN 'Tomar una pastilla cada 8 horas con un vaso de agua.'
        WHEN 5 THEN 'Tomar dos pastillas con el estómago vacío por la mañana.'
        WHEN 6 THEN 'Tomar una pastilla con un vaso de leche antes de dormir.'
        WHEN 7 THEN 'Tomar una pastilla con un poco de comida cada 6 horas.'
        WHEN 8 THEN 'Tomar dos pastillas por la mañana y una por la noche.'
        WHEN 9 THEN 'Tomar una pastilla con un vaso grande de agua después de comer.'
        WHEN 10 THEN 'Tomar una pastilla con una comida ligera por la tarde.'
        WHEN 11 THEN 'Tomar una pastilla con el desayuno y otra con la cena.'
        WHEN 12 THEN 'Tomar una pastilla justo antes de ir a la cama.'
        WHEN 13 THEN 'Tomar una pastilla después de una comida pesada.'
        WHEN 14 THEN 'Tomar dos pastillas con un vaso de agua cada 12 horas.'
        WHEN 15 THEN 'Tomar una pastilla con la comida principal del día.'
        WHEN 16 THEN 'Tomar una pastilla con el almuerzo y otra antes de dormir.'
        WHEN 17 THEN 'Tomar una pastilla con un vaso de jugo por la mañana.'
        WHEN 18 THEN 'Tomar una pastilla con cada comida principal del día.'
        WHEN 19 THEN 'Tomar una pastilla por la mañana y otra por la tarde.'
        WHEN 20 THEN 'Tomar dos pastillas antes de acostarse con un vaso de agua.'
        ELSE 'Indicaciones no disponibles.'
    END;

    RETURN indicaciones_m;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `generar_observaciones` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `generar_observaciones`() RETURNS varchar(255) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE observacion VARCHAR(255);
    SET observacion = CASE FLOOR(1 + RAND() * 20)
        WHEN 1 THEN 'El paciente presenta síntomas leves.'
        WHEN 2 THEN 'Necesita seguimiento en una semana.'
        WHEN 3 THEN 'Recomendar reposo absoluto.'
        WHEN 4 THEN 'Posible reacción alérgica a medicamentos.'
        WHEN 5 THEN 'Los signos vitales son estables.'
        WHEN 6 THEN 'Necesidad de exámenes adicionales.'
        WHEN 7 THEN 'El tratamiento ha mostrado mejoría.'
        WHEN 8 THEN 'Riesgo de complicaciones si no se sigue el tratamiento.'
        WHEN 9 THEN 'Se observó aumento de presión arterial.'
        WHEN 10 THEN 'Dolor persistente en la zona afectada.'
        WHEN 11 THEN 'El paciente debe evitar esfuerzos físicos.'
        WHEN 12 THEN 'Signos de deshidratación.'
        WHEN 13 THEN 'Requiere consulta con especialista.'
        WHEN 14 THEN 'El paciente muestra ansiedad moderada.'
        WHEN 15 THEN 'El tratamiento debe continuar por dos semanas más.'
        WHEN 16 THEN 'Alergia al polvo detectada.'
        WHEN 17 THEN 'El paciente se encuentra en recuperación.'
        WHEN 18 THEN 'Necesario ajustar la dosis del medicamento.'
        WHEN 19 THEN 'Debe mantenerse hidratado.'
        WHEN 20 THEN 'No hay signos de infección.'
    END;
    RETURN observacion;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hola` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `hola`() RETURNS int
    DETERMINISTIC
BEGIN

RETURN 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_estatus_bd` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_estatus_bd`(v_password VARCHAR(20))
BEGIN  
	
    IF v_password = "xYz$123" THEN
	-- Subquery / Subconsultas
    
	(SELECT "TABLAS CATALOGO" as Tabla, "--------------------" as TotalRegistros, 
    "--------------" as TipoTabla, "--------------" as Jerarquia, "--------------" as UDN_Owner, "--------------"  as UDN_Editors,  "--------------" as UDN_Readers)
	UNION
	(SELECT "tbb_aprobaciones" as Tabla,   
    (SELECT COUNT(*) FROM  tbb_aprobaciones) as TotalRegistros, "Tabla Débil", "Genérica", "Dirección General", "Dirección General", "Todos")
    UNION
    (SELECT "tbc_areas_medicas" as Tabla,   
    (SELECT COUNT(*) FROM  tbc_areas_medicas) as TotalRegistros, "Tabla Fuerte", "Genérica", "Áreas Médicas", "Recursos Humanos, Dirección General", "Todos")
    UNION
	(SELECT "tbc_consumibles" as Tabla,   
    (SELECT COUNT(*) FROM  tbc_consumibles) as TotalRegistros, "Tabla Cátalogo", "Genérica", "Farmacia Intrahospitalaria", "Farmacia Intrahospitalaria, Recursos Materiales", "Todos")
    UNION
    (SELECT "tbc_departamentos" as Tabla,
    (SELECT COUNT(*) FROM  tbc_departamentos) as TotalRegistros, "Tabla Fuerte", "Genérica", "Recursos Humanos", "Recursos Humanos, Dirección General", "Todos")
    UNION
    (SELECT "tbc_espacios" as Tabla,   
    (SELECT COUNT(*) FROM  tbc_espacios) as TotalRegistros, "Tabla Fuerte", "Genérica", "Dirección General", "Dirección General, Recursos Materiales, Programación Quirúrgica, Farmacia Intrahospitalaria, Radiología e Imagen, Pediatría, Recursos Humanos, Registros Médicos, Comité de Trasplante", "Todos")
     UNION
    (SELECT "tbc_estudios" as Tabla,   
    (SELECT COUNT(*) FROM  tbc_estudios) as TotalRegistros, "Tabla Catalogo", "Genérica", "Radiologia e Imagen", "Dirección General, Radiología e Imagen, Registros Médicos, Programación Quirúrgica", "Todos")
    UNION
	(SELECT "tbc_medicamentos" as Tabla,   
    (SELECT COUNT(*) FROM  tbc_medicamentos) as TotalRegistros, "Tabla Fuerte", "Genérica", "Farmacia Intrahospitalaria", "Farmacia Intrahospitalaria, Recursos Materiales", "Todos")
   UNION
   (SELECT "tbc_organos" AS Tabla,
	(SELECT COUNT(*) FROM tbc_organos) AS TotalRegistros, "Tabla Fuerte", "Generica", "Comite de Transplantes", "Direccion General, Comite de Transpalntes", "Direccion General, Comite de Transpalntes")    UNION
    (SELECT "tbc_puestos" as Tabla,   
    (SELECT COUNT(*) FROM  tbc_puestos) as TotalRegistros, "Tabla Debil", "Genérica", "Personal Medico",  "Personal Medico, Recursos Humanos", "Todos")
    UNION
    (SELECT "tbc_roles" as Tabla,   
    (SELECT COUNT(*) FROM  tbc_roles) as TotalRegistros, "Tabla Fuerte", "Genérica", "Dirección General", "Dirección General, Registros Médicos, Recursos Humanos", "Todos")
    UNION
     (SELECT "tbc_servicios_medicos" as Tabla,   
    (SELECT COUNT(*) FROM  tbc_servicios_medicos) as TotalRegistros, "Tabla Cátalogo", "Genérica", "Radiología e Imagen", "Dirección General, Radiología e Imagen, Pediatria, Recursos Humanos, Programacion Quirurgica, Registros Médicos,", "Recursos Materiales")
    UNION
    
    
   

    (SELECT "TABLAS BASE" as Tabla, "--------------------" as TotalRegistros
    , "--------------" as TipoTabla, "--------------" as Jerarquia, "--------------" as UDN_Owner, "--------------"  as UDN_Editors,  "--------------" as UDN_Readers)
    UNION
    (SELECT "tbb_citas_medicas" AS Tabla,
	(select count(*) from tbb_citas_medicas) as TotalRegistros, "Tabla Débil", "Genérica", "Radiologia e Imagen","Dirección General, Radiología e Imagen, Pediatria, Recursos Humanos, Programación Quirúrgica, Registros Médicos, 
  Farmacia Intrahospitalaria, Comité de Trasplante", "Todos")
	UNION
	(SELECT "tbb_cirugias" AS Tabla,
	(select count(*) from tbb_cirugias) as TotalRegistros, "Tabla Débil", "Genérica", "Programación Quirúrgica", "Dirección General, Radiología e Imagen, Pediatría, Recursos Materiales, Comité de Trasplantes, Farmacia Intrahospitalaria", "Todos")
	UNION
    (SELECT "tbb_nacimientos" AS Tabla,
	(select count(*) from tbb_nacimientos) as TotalRegistros, "Tabla Débil", "Genérica", "Pediatria","Pediatria, Registros Médicos", "Pediatria, Registros Médicos, Cirugia, Dirección General")
    UNION
    (SELECT "tbb_pacientes" AS Tabla,
	(select count(*) from tbb_pacientes) as TotalRegistros, "Tabla Débil", "Subentidad", "Registros Médicos","Registros Médicos", "Radiología e Imagen, Pediatría, Programación Quirúrgica, Registros Médicos, Farmacia Intrahospitalaria, Comité de Transplantes, Pacientes")
	UNION
    (SELECT "tbb_personal_medico" AS Tabla,
	(select count(*) from tbb_personal_medico) as TotalRegistros, "Tabla Débil", "Subentidad", "Recursos Humanos","Recursos Humanos, Registros Médicos", "Todos")
    UNION
	(SELECT "tbd_solicitudes" AS Tabla,
	(select count(*) from tbd_solicitudes) as TotalRegistros, "Tabla Débil", "Genérica", "Comite de Transplantes", "Comite de Transplantes, Personal Medico", "Direccion General, Radiologia e Imagen, Pediatria, Recursos Humanos, Programacion Quirurgica, Farmacia Intrahospitalaria, Comite de Transplantes")
    UNION
    (SELECT "tbb_usuarios" as Tabla, 
    (SELECT COUNT(*) FROM  tbb_usuarios) as TotalRegistros, "Tabla Débil", "Subentidad", "Registros Médicos", "Registros Médicos, Paciente", "Todos"  )
    UNION
    
	(SELECT "tbb_personas" AS Tabla,
	(select count(*) from tbb_personas) as TotalRegistros, "Tabla Débil", "Superentidad", "Registros Medicos", "Recursos Humanos", "Todos")
	UNION
    (SELECT "tbb_valoraciones_medicas" AS Tabla,
	(select count(*) from tbb_valoraciones_medicas) as TotalRegistros, "Tabla Débil", "Genérica", "Pediatria","Pediatria, Registros Médicos", "Todos")
	UNION
    

    
    (SELECT "TABLAS DERIVADAS" as Tabla, "--------------------" as TotalRegistros,
    "--------------" as TipoTabla, "--------------" as Jerarquia, "--------------" as UDN_Owner, "--------------"  as UDN_Editors,  "--------------" as UDN_Readers)
   UNION
    (SELECT "tbd_departamentos_servicios" as Tabla, 
    (SELECT COUNT(*) FROM  tbd_departamentos_servicios) as TotalRegistros, "Tabla Derivada", "Genérica", "Radiología e Imagen", "Dirección General, Radiología e Imagen, Pediatria, Recursos Humanos, Programacion Quirurgica, Registros Médicos", "Todos")
   UNION
    (SELECT "tbd_dispensaciones" as Tabla, 
    (SELECT COUNT(*) FROM  tbd_dispensaciones) as TotalRegistros, "Tabla Derivada", "Genérica", "Farmacia Intrahospitalaria", "Farmacia Intrahospitalaria", "Pacientes, Registros Medicos")
    
    UNION
    (SELECT "tbd_lotes_medicamentos" as Tabla, 
    (SELECT COUNT(*) FROM  tbd_lotes_medicamentos) as TotalRegistros, "Tabla Derivada", "Genérica", "Farmacia Intrahospitalaria", "Farmacia Intrahospitalaria, Dirección General", "Todos")
    UNION
    (SELECT "tbd_usuarios_roles" as Tabla, 
    (SELECT COUNT(*) FROM  tbd_usuarios_roles) as TotalRegistros, "Tabla Derivada", "Genérica", "Registros Médicos", "Registros Médicos", "Todos")
	UNION
    (SELECT "tbd_expedientes_clinicos" as Tabla, 
    (SELECT COUNT(*) FROM  tbd_expedientes_clinicos) as TotalRegistros, "Tabla Derivada", "Genérica", "Registros Médicos", "Personal Medico", "Todos")
    UNION
    (SELECT "tbd_recetas_medicas" as Tabla, 
    (SELECT COUNT(*) FROM  tbd_recetas_medicas) as TotalRegistros, "Tabla Derivada", "Genérica", "Pediatria", "Personal Medico", "Personal Medico,Farmacia, Pidiatria")
    UNION
	(SELECT "tbd_resultados_estudios" as Tabla, 
    (SELECT COUNT(*) FROM  tbd_resultados_estudios) as TotalRegistros, "Tabla Derivada", "Genérica", "Radiología e Imagen", "Dirección General, Radiología e Imagen ", "Comité de Trasplantes, Dirección General, Farmacia Intrahospitalaria, Pediatría, Programación Quirúrgica, Radiología e Imagen, Recursos Materiales, Registros Médicos")
    UNION
    (SELECT "TABLAS ISLA" as Tabla, "--------------------" as TotalRegistros,
    "--------------" as TipoTabla, "--------------" as Jerarquia, "--------------" as UDN_Owner, "--------------"  as UDN_Editors,  "--------------" as UDN_Readers)
    UNION
    (SELECT "tbi_bitacora" as Tabla, 
    (SELECT COUNT(*) FROM  tbi_bitacora) as TotalRegistros, "Tabla Isla", "Genérica", "Dirección General", "-", "-");
    
    
    
    ELSE 
      SELECT "La contraseña es incorrecta, no puedo mostrarte el 
      estatus de la Base de Datos" AS ErrorMessage;
    
    END IF;
		

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insertar_aprobaciones` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`carlos.crespo`@`%` PROCEDURE `sp_insertar_aprobaciones`(IN num_solicitudes INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE status ENUM('En Proceso', 'Pausado', 'Aprobado', 'Reprogramado', 'Cancelado');
    DECLARE tipo ENUM('Servicio Interno', 'Traslados', 'Subrogado', 'Administrativo');
    DECLARE comentario TEXT;
    DECLARE idx INT;
    DECLARE fecha_registro DATETIME;
    DECLARE fecha_actualizacion DATETIME;

    WHILE i <= num_solicitudes DO
        -- Generar fecha de registro aleatoria entre el año 2000 y la fecha actual
        SET fecha_registro = DATE_ADD('2000-01-01', INTERVAL FLOOR(RAND() * DATEDIFF(NOW(), '2000-01-01')) DAY);
        SET fecha_registro = DATE_ADD(fecha_registro, INTERVAL FLOOR(RAND() * 24) HOUR); -- Agregar horas aleatorias
        SET fecha_registro = DATE_ADD(fecha_registro, INTERVAL FLOOR(RAND() * 60) MINUTE); -- Agregar minutos aleatorios
        SET fecha_registro = DATE_ADD(fecha_registro, INTERVAL FLOOR(RAND() * 60) SECOND); -- Agregar segundos aleatorios

        -- Generar valores aleatorios para cada iteración
        SET tipo = ELT(FLOOR(1 + (RAND() * 4)), 'Servicio Interno', 'Traslados', 'Subrogado', 'Administrativo');
        SET status = ELT(FLOOR(1 + (RAND() * 5)), 'En Proceso', 'Pausado', 'Aprobado', 'Reprogramado', 'Cancelado');

        -- Verificar si hay una actualización previa para esta solicitud y si el nuevo status es "En Proceso"
        SELECT MAX(fecha_actualizacion) INTO fecha_actualizacion
        FROM tbb_aprobaciones
        WHERE solicitud_id = i;

        IF fecha_actualizacion IS NOT NULL AND status = 'En Proceso' THEN
            -- Si hay una fecha de actualización previa y el nuevo estatus es "En Proceso", seleccionar otro estatus aleatorio que no sea "En Proceso"
            SET status = ELT(FLOOR(2 + (RAND() * 4)), 'Pausado', 'Aprobado', 'Reprogramado', 'Cancelado'); -- Evitar 'En Proceso'
        ELSE
            -- Generar fecha de actualización dentro de un rango de 2 a 3 días si el estatus no está en "En Proceso"
            IF status != 'En Proceso' THEN
                SET fecha_actualizacion = DATE_ADD(fecha_registro, INTERVAL 2 + FLOOR(RAND() * 2) DAY); -- Fecha aleatoria entre 2 y 3 días después de la fecha de registro
                SET fecha_actualizacion = DATE_ADD(fecha_actualizacion, INTERVAL FLOOR(RAND() * 24) HOUR); -- Agregar horas aleatorias
                SET fecha_actualizacion = DATE_ADD(fecha_actualizacion, INTERVAL FLOOR(RAND() * 60) MINUTE); -- Agregar minutos aleatorios
                SET fecha_actualizacion = DATE_ADD(fecha_actualizacion, INTERVAL FLOOR(RAND() * 60) SECOND); -- Agregar segundos aleatorios
            ELSE
                SET fecha_actualizacion = NULL; -- Dejar fecha_actualizacion como NULL si el estatus es "En Proceso"
            END IF;
        END IF;

        SET idx = FLOOR(1 + (RAND() * 100)); -- Generar un número aleatorio entre 1 y 100

        -- Selección de comentario aleatorio
        CASE idx
            WHEN 1 THEN SET comentario = 'Paciente muestra signos de mejoría.';
            WHEN 2 THEN SET comentario = 'Requiere monitoreo constante.';
            WHEN 3 THEN SET comentario = 'Se recomienda cambio de medicación.';
            WHEN 4 THEN SET comentario = 'Alta programada para mañana.';
            WHEN 5 THEN SET comentario = 'Necesita intervención quirúrgica.';
            WHEN 6 THEN SET comentario = 'Paciente estable, continuar tratamiento actual.';
            WHEN 7 THEN SET comentario = 'Realizar análisis de sangre adicional.';
            WHEN 8 THEN SET comentario = 'Se observa reacción alérgica, cambiar antibiótico.';
            WHEN 9 THEN SET comentario = 'Consultar con especialista en cardiología.';
            WHEN 10 THEN SET comentario = 'Requiere traslado a unidad de cuidados intensivos.';
            WHEN 11 THEN SET comentario = 'Paciente presenta fiebre alta.';
            WHEN 12 THEN SET comentario = 'Iniciar tratamiento con antibióticos.';
            WHEN 13 THEN SET comentario = 'Mantener en observación 24 horas.';
            WHEN 14 THEN SET comentario = 'Evaluar función renal y hepática.';
            WHEN 15 THEN SET comentario = 'Paciente no responde al tratamiento.';
            WHEN 16 THEN SET comentario = 'Administrar líquidos intravenosos.';
            WHEN 17 THEN SET comentario = 'Preparar para radiografía de tórax.';
            WHEN 18 THEN SET comentario = 'Recomendar dieta baja en sodio.';
            WHEN 19 THEN SET comentario = 'Paciente en recuperación postoperatoria.';
            WHEN 20 THEN SET comentario = 'Reevaluar síntomas en 48 horas.';
            WHEN 21 THEN SET comentario = 'Realizar electrocardiograma (ECG).';
            WHEN 22 THEN SET comentario = 'Observar por posibles complicaciones.';
            WHEN 23 THEN SET comentario = 'Paciente presenta dolor agudo.';
            WHEN 24 THEN SET comentario = 'Administrar analgésicos según prescripción.';
            WHEN 25 THEN SET comentario = 'Evaluar función pulmonar.';
            WHEN 26 THEN SET comentario = 'Paciente reporta mareos frecuentes.';
            WHEN 27 THEN SET comentario = 'Recomendar descanso absoluto.';
            WHEN 28 THEN SET comentario = 'Administrar antihistamínicos.';
            WHEN 29 THEN SET comentario = 'Programar sesión de fisioterapia.';
            WHEN 30 THEN SET comentario = 'Realizar pruebas de función tiroidea.';
            WHEN 31 THEN SET comentario = 'Paciente presenta náuseas y vómitos.';
            WHEN 32 THEN SET comentario = 'Iniciar tratamiento para hipertensión.';
            WHEN 33 THEN SET comentario = 'Recomendar control de glucemia.';
            WHEN 34 THEN SET comentario = 'Paciente muestra signos de deshidratación.';
            WHEN 35 THEN SET comentario = 'Administrar suero oral.';
            WHEN 36 THEN SET comentario = 'Evaluar respuesta a la medicación.';
            WHEN 37 THEN SET comentario = 'Paciente en estado crítico.';
            WHEN 38 THEN SET comentario = 'Mantener en unidad de cuidados intensivos.';
            WHEN 39 THEN SET comentario = 'Realizar tomografía computarizada (TC).';
            WHEN 40 THEN SET comentario = 'Paciente con historial de alergias.';
            WHEN 41 THEN SET comentario = 'Administrar epinefrina en caso de emergencia.';
            WHEN 42 THEN SET comentario = 'Monitorizar niveles de oxígeno en sangre.';
            WHEN 43 THEN SET comentario = 'Paciente requiere ventilación asistida.';
            WHEN 44 THEN SET comentario = 'Evaluar necesidad de transfusión sanguínea.';
            WHEN 45 THEN SET comentario = 'Paciente presenta síntomas de infección.';
            WHEN 46 THEN SET comentario = 'Iniciar aislamiento preventivo.';
            WHEN 47 THEN SET comentario = 'Realizar pruebas de función hepática.';
            WHEN 48 THEN SET comentario = 'Paciente en estado de shock.';
            WHEN 49 THEN SET comentario = 'Administrar fluidos intravenosos rápidamente.';
            WHEN 50 THEN SET comentario = 'Recomendar consulta con endocrinólogo.';
            WHEN 51 THEN SET comentario = 'Paciente presenta convulsiones.';
            WHEN 52 THEN SET comentario = 'Administrar anticonvulsivantes.';
            WHEN 53 THEN SET comentario = 'Recomendar seguimiento neurológico.';
            WHEN 54 THEN SET comentario = 'Paciente con dolor torácico persistente.';
            WHEN 55 THEN SET comentario = 'Realizar angiografía coronaria.';
            WHEN 56 THEN SET comentario = 'Paciente presenta erupción cutánea.';
            WHEN 57 THEN SET comentario = 'Administrar corticosteroides tópicos.';
            WHEN 58 THEN SET comentario = 'Evaluar signos de sepsis.';
            WHEN 59 THEN SET comentario = 'Iniciar tratamiento antibiótico de amplio espectro.';
            WHEN 60 THEN SET comentario = 'Paciente con historial de enfermedades cardíacas.';
            WHEN 61 THEN SET comentario = 'Recomendar prueba de esfuerzo.';
            WHEN 62 THEN SET comentario = 'Paciente presenta dificultad respiratoria.';
            WHEN 63 THEN SET comentario = 'Administrar broncodilatadores.';
            WHEN 64 THEN SET comentario = 'Paciente en recuperación post-anestesia.';
            WHEN 65 THEN SET comentario = 'Monitorizar signos vitales cada 30 minutos.';
            WHEN 66 THEN SET comentario = 'Realizar ecografía abdominal.';
            WHEN 67 THEN SET comentario = 'Paciente con signos de anemia.';
            WHEN 68 THEN SET comentario = 'Administrar suplemento de hierro.';
            WHEN 69 THEN SET comentario = 'Paciente requiere evaluación psiquiátrica.';
            WHEN 70 THEN SET comentario = 'Iniciar terapia cognitivo-conductual.';
            WHEN 71 THEN SET comentario = 'Paciente con historial de diabetes.';
            WHEN 72 THEN SET comentario = 'Recomendar control estricto de glucosa.';
            WHEN 73 THEN SET comentario = 'Realizar prueba de función pulmonar.';
            WHEN 74 THEN SET comentario = 'Paciente presenta ictericia.';
            WHEN 75 THEN SET comentario = 'Evaluar función hepática y biliar.';
            WHEN 76 THEN SET comentario = 'Paciente con síntomas de migraña.';
            WHEN 77 THEN SET comentario = 'Administrar triptanos según prescripción.';
            WHEN 78 THEN SET comentario = 'Realizar resonancia magnética (RM).';
            WHEN 79 THEN SET comentario = 'Paciente con dolor lumbar agudo.';
            WHEN 80 THEN SET comentario = 'Recomendar fisioterapia y ejercicios de estiramiento.';
            WHEN 81 THEN SET comentario = 'Paciente muestra signos de fatiga crónica.';
            WHEN 82 THEN SET comentario = 'Evaluar por posibles trastornos del sueño.';
            WHEN 83 THEN SET comentario = 'Paciente con historial de cáncer.';
            WHEN 84 THEN SET comentario = 'Programar seguimiento oncológico.';
            WHEN 85 THEN SET comentario = 'Paciente presenta hipertensión arterial.';
            WHEN 86 THEN SET comentario = 'Ajustar medicación antihipertensiva.';
            WHEN 87 THEN SET comentario = 'Realizar evaluación oftalmológica.';
            WHEN 88 THEN SET comentario = 'Paciente con dolor abdominal persistente.';
            WHEN 89 THEN SET comentario = 'Realizar endoscopia digestiva alta.';
            WHEN 90 THEN SET comentario = 'Paciente con antecedentes de asma.';
            WHEN 91 THEN SET comentario = 'Administrar corticosteroides inhalados.';
            WHEN 92 THEN SET comentario = 'Paciente presenta signos de depresión.';
            WHEN 93 THEN SET comentario = 'Iniciar tratamiento con antidepresivos.';
            WHEN 94 THEN SET comentario = 'Recomendar terapia psicológica.';
            WHEN 95 THEN SET comentario = 'Paciente en estado de desnutrición.';
            WHEN 96 THEN SET comentario = 'Iniciar dieta rica en nutrientes.';
            WHEN 97 THEN SET comentario = 'Paciente presenta dolor articular.';
            WHEN 98 THEN SET comentario = 'Administrar antiinflamatorios no esteroideos (AINEs).';
            WHEN 99 THEN SET comentario = 'Recomendar seguimiento con reumatólogo.';
            WHEN 100 THEN SET comentario = 'Paciente requiere atención odontológica.';
            ELSE SET comentario = 'No hay comentarios adicionales.';
        END CASE;

        -- Insertar la solicitud en la tabla
        INSERT INTO tbb_aprobaciones (id, personal_medico_id, solicitud_id, comentario, estatus, tipo, fecha_registro, fecha_actualizacion)
        VALUES (i, i, i, comentario, status, tipo, fecha_registro, fecha_actualizacion);

        -- Actualizar aleatoriamente algunos registros después de la inserción
        IF RAND() < 0.5 THEN -- Aproximadamente el 50% de las veces
            -- Generar un nuevo tipo y estatus aleatorio para un registro aleatorio
            UPDATE tbb_aprobaciones
            SET tipo = ELT(FLOOR(1 + (RAND() * 4)), 'Servicio Interno', 'Traslados', 'Subrogado', 'Administrativo'),
                estatus = ELT(FLOOR(1 + (RAND() * 5)), 'En Proceso', 'Pausado', 'Aprobado', 'Reprogramado', 'Cancelado')
            WHERE id = i AND estatus != 'En Proceso'; -- Evitar actualizar a 'En Proceso'
        END IF;
        
        -- Eliminar Registros de manera aleatoria
        IF RAND() < 0.2 then  -- Aproximadamente el 20% de las veces
			DELETE FROM tbb_aprobaciones 
			WHERE id = i; -- Elimina el Registro actual
        END IF;

        -- Incrementar el contador
        SET i = i + 1;
    END WHILE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insertar_horario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`DiegoOliver`@`%` PROCEDURE `sp_insertar_horario`(
    IN p_empleado_id INT,
    IN p_nombre VARCHAR(100),
    IN p_especialidad VARCHAR(100),
    IN p_dia_semana VARCHAR(20),
    IN p_hora_inicio TIME,
    IN p_hora_fin TIME,
    IN p_turno ENUM('Matutino', 'Vespertino', 'Nocturno'),
    IN p_nombre_departamento VARCHAR(100),
    IN p_nombre_sala VARCHAR(100)
)
BEGIN
    INSERT INTO tbd_horarios (
        empleado_id, 
        nombre, 
        especialidad, 
        dia_semana, 
        hora_inicio, 
        hora_fin, 
        turno, 
        nombre_departamento, 
        nombre_sala
    ) VALUES (
        p_empleado_id, 
        p_nombre, 
        p_especialidad, 
        p_dia_semana, 
        p_hora_inicio, 
        p_hora_fin, 
        p_turno, 
        p_nombre_departamento, 
        p_nombre_sala
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_limpiar_bd` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_limpiar_bd`(v_password varchar(10))
    DETERMINISTIC
BEGIN
	IF v_password = "1234" THEN
	
    -- Eliminamos los datos de las tablas débiles
    DELETE FROM tbd_usuarios_roles;
    DELETE FROM tbb_citas_medicas;
    ALTER TABLE tbb_citas_medicas AUTO_INCREMENT=1;
    
    
    DELETE FROM tbd_departamentos_servicios;
     delete from tbd_recetas_detalles;
    ALTER TABLE tbd_recetas_detalles AUTO_INCREMENT=1;
    
    delete from tbd_receta_medicamentos;
    ALTER TABLE tbd_receta_medicamentos AUTO_INCREMENT=1;
    
    delete from tbd_recetas_medicas;
    alter table tbd_recetas_medicas AUTO_INCREMENT=1;
    
   
     DELETE FROM tbc_espacios;
	ALTER TABLE tbc_espacios AUTO_INCREMENT=1;
    
	DELETE FROM tbc_servicios_medicos;
    ALTER TABLE tbc_servicios_medicos AUTO_INCREMENT=1;
    /* DELETE FROM tbc_areas_medicas;
    ALTER TABLE tbc_areas_medicas AUTO_INCREMENT=1;*/
    delete from tbb_cirugias;
	ALTER TABLE tbb_cirugias AUTO_INCREMENT=1;
    
	DELETE FROM tbd_resultados_estudios;
	ALTER TABLE tbd_resultados_estudios AUTO_INCREMENT=1;
    DELETE FROM tbd_dispensaciones;
	ALTER TABLE tbd_dispensaciones AUTO_INCREMENT=1;
    DELETE FROM tbd_lotes_medicamentos;
	ALTER TABLE tbd_lotes_medicamentos AUTO_INCREMENT=1;
	DELETE FROM tbc_consumibles;
	ALTER TABLE tbc_consumibles AUTO_INCREMENT=1;
    DELETE FROM tbd_solicitudes;
	ALTER TABLE tbd_solicitudes AUTO_INCREMENT=1;
    DELETE FROM tbc_organos;
	ALTER TABLE tbc_organos AUTO_INCREMENT=1;
   
	DELETE FROM tbb_aprobaciones;
	ALTER TABLE tbb_aprobaciones AUTO_INCREMENT=1;



    -- Eliminamos los datos de las tablas fuertes
	DELETE FROM tbb_pacientes;
	ALTER TABLE tbb_pacientes AUTO_INCREMENT=1;
    DELETE FROM tbb_usuarios;
    ALTER TABLE tbb_usuarios AUTO_INCREMENT=1;
	DELETE FROM tbd_expedientes_clinicos;
	ALTER TABLE tbd_expedientes_clinicos AUTO_INCREMENT=1;
    DELETE FROM tbd_recetas_medicas;
    ALTER TABLE tbd_recetas_medicas AUTO_INCREMENT=1;
    DELETE FROM tbb_personal_medico;    
    DELETE FROM tbb_personas;
	ALTER TABLE tbb_personas AUTO_INCREMENT=1;
    DELETE FROM tbc_roles;
    ALTER TABLE tbc_roles AUTO_INCREMENT=1;
    UPDATE tbc_espacios SET espacio_superior_id = NULL;
	DELETE FROM tbc_espacios;
    ALTER TABLE tbc_espacios AUTO_INCREMENT=1;
    
    DELETE FROM tbc_puestos;
    ALTER TABLE tbc_puestos AUTO_INCREMENT=1;
    DELETE FROM tbc_estudios;
    ALTER TABLE tbc_estudios AUTO_INCREMENT=1;

	DELETE FROM tbb_valoraciones_medicas;
    ALTER TABLE tbb_valoraciones_medicas AUTO_INCREMENT=1;
    DELETE FROM tbb_nacimientos;
    ALTER TABLE tbb_nacimientos AUTO_INCREMENT=1;
    DELETE FROM tbc_medicamentos;
    ALTER TABLE tbc_medicamentos AUTO_INCREMENT=1;
    
    DELETE FROM tbi_bitacora;
	ALTER TABLE tbi_bitacora AUTO_INCREMENT=1;
    
    	ELSE
		SELECT "La contraseña es incorrecta" AS Mensaje;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_limpiar_bd_recetas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_limpiar_bd_recetas`(v_password varchar(10))
    DETERMINISTIC
BEGIN
	IF v_password = "1234" THEN
	
    -- Eliminamos los datos de las tablas débiles
   
    DELETE FROM tbb_citas_medicas;
    ALTER TABLE tbb_citas_medicas AUTO_INCREMENT=1;
    
     delete from tbd_recetas_detalles;
    ALTER TABLE tbd_recetas_detalles AUTO_INCREMENT=1;
    
    delete from tbd_receta_medicamentos;
    ALTER TABLE tbd_receta_medicamentos AUTO_INCREMENT=1;
    
    delete from tbd_recetas_medicas;
    alter table tbd_recetas_medicas AUTO_INCREMENT=1;
    
    	ELSE
		SELECT "La contraseña es incorrecta" AS Mensaje;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_Aprobaciones` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`carlos.crespo`@`%` PROCEDURE `sp_poblar_Aprobaciones`(IN v_password VARCHAR(255))
BEGIN
    IF v_password = '1234' THEN
        -- Insertar
		INSERT INTO tbb_aprobaciones (`id`, `pm_id`, `solicitud_id`, `comentario`, `estatus`, `tipo`, `fecha_registro`) 
					VALUES ('1', '1', '1', 'Preuba de Solicitud', 'En Proceso', 'Servicio Interno', now());

		INSERT INTO tbb_aprobaciones (`id`, `pm_id`, `solicitud_id`, `comentario`, `estatus`, `tipo`, `fecha_registro`) 
					VALUES ('2', '2', '2', 'Traslado a la sala de Cuidados Intensivos', 'En Proceso', 'Servicio Interno', now());

		INSERT INTO tbb_aprobaciones (`id`, `pm_id`, `solicitud_id`, `comentario`, `estatus`, `tipo`, `fecha_registro`) 
					VALUES ('3', '3', '3', 'Traslado a la sala de Cuidados Intensivos', 'En Proceso', 'Servicio Interno', now());
                    
		INSERT INTO tbb_aprobaciones (`id`, `pm_id`, `solicitud_id`, `comentario`, `estatus`, `tipo`, `fecha_registro`) 
					VALUES ('4', '4', '4', 'Solicitud de Cunas en Area de Maternida', 'Aprobado', 'Servicio Interno', now());
                    
		INSERT INTO tbb_aprobaciones (`id`, `pm_id`, `solicitud_id`, `comentario`, `estatus`, `tipo`, `fecha_registro`) 
					VALUES ('5', '5', '5', 'Solicitud de Apertura de Area de Maternidad ', 'Aprobado', 'Servicio Interno', now());
        
        -- Actualizar
		UPDATE tbb_aprobaciones SET Estatus = 'Aprobado' WHERE Estatus = 'En Proceso' and id = 1;
		UPDATE tbb_aprobaciones SET tipo = 'Subrogado' WHERE tipo = 'Servicio Interno' and solicitud_id  = 4;
		UPDATE tbb_aprobaciones SET Comentario = 'Solicitud de traslado a la UTI' WHERE Comentario = 'Preuba de Solicitud' and id = 1;
        
        -- Eliminar
		delete from tbb_aprobaciones where id = 3;
        
    ELSE
        SELECT 'La contraseña es incorrecta, no puedo mostrarte los nacimientos de la base de datos' AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_areas_medicas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`america.estudillo`@`%` PROCEDURE `sp_poblar_areas_medicas`(IN v_password VARCHAR(50))
BEGIN
    DECLARE id_val INT;

    IF v_password = "xYz$123" THEN
        -- Realizar la inserción inicial
        INSERT INTO tbc_areas_medicas (Nombre, Descripcion, Estatus, Fecha_Registro, Fecha_Actualizacion)
        VALUES
        ('Servicios Medicos', 'Por definir', 'Activo', '2024-01-21 16:00:41', NOW()),
        ('Servicios de Apoyo', 'Por definir', 'Activo', '2024-01-21 16:06:31', NOW()),
        ('Servicios Medico - Administrativos', 'Por definir', 'Activo', '2024-01-21 16:06:31', NOW()),
        ('Servicios de Enfermeria', 'Por definir', 'Activo', '2024-01-21 16:06:31', NOW()),
        ('Departamentos Administrativos', 'Por definir', 'Activo', '2024-01-21 16:06:31', NOW()),
        ('Nueva Área Médica', 'Por definir', 'Activo', '2024-06-18 12:00:00', NOW()); -- Inserción de la nueva área médica

        -- Obtener el último ID insertado
        SET id_val = LAST_INSERT_ID();

        -- Mostrar los datos insertados
        SELECT * FROM tbc_areas_medicas;

        -- Actualizar el estado a 'Inactivo' para el registro 'Nueva Área Médica'
        UPDATE tbc_areas_medicas
        SET Estatus = 'Inactivo'
        WHERE Nombre = 'Nueva Área Médica';

        -- Mostrar los datos actualizados
        SELECT * FROM tbc_areas_medicas;

        -- Eliminar el registro 'Nueva Área Médica'
        DELETE FROM tbc_areas_medicas
        WHERE Nombre = 'Nueva Área Médica';

        -- Mostrar los datos después de la eliminación
        SELECT * FROM tbc_areas_medicas;

    ELSE
        -- Mostrar mensaje de error si la contraseña es incorrecta
        SELECT 'Contraseña incorrecta' AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_cirugias` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`brayan.gutierrez`@`%` PROCEDURE `sp_poblar_cirugias`(v_password VARCHAR (20))
BEGIN

IF v_password = "xYz$123" THEN
        INSERT INTO tbb_cirugias (
            id, tipo, nombre, descripcion, personal_medico, paciente, nivel_urgencia, 
            horario, observaciones, fecha_registro, valoracion_medica, estatus, consumible, 
            espacio_medico, Fecha_Actualizacion
        ) VALUES
        (	DEFAULT,
            'Ortopédica', 
            'Reemplazo de Rodilla', 
            'Cirugía para reemplazar una articulación de rodilla dañada con una prótesis.',
            'Dr. Juan Pérez, Dr. Ana García', 
            'Pedro Martínez', 
            'Alto', 
            '2024-06-20 09:00:00', 
            'Paciente con antecedentes de artritis severa.', 
            default,
            'Valoración preoperatoria completa, paciente en condiciones adecuadas.', 
            'Programada', 
            'Prótesis de rodilla, Instrumental quirúrgico', 
            'Quirófano 1', 
            NOW()
        ),
        (	DEFAULT,
            'Ortopédica', 
            'Reemplazo de Rodilla', 
            'Cirugía para reemplazar una articulación de rodilla dañada con una prótesis.',
            'Dr. Bruno Mars, Dr. Ana Huevara', 
            'Alexis Carrillo', 
            'Alto', 
            '2022-06-20 09:00:00', 
            'Paciente con antecedentes de artritis severa.', 
            default,
            'Valoración preoperatoria completa, paciente en condiciones adecuadas.', 
            'Programada', 
            'Prótesis de rodilla, Instrumental quirúrgico', 
            'Quirófano 1', 
            NOW()
        ),
         (	DEFAULT,
            'Ginecológica', 
            'Cesárea', 
            'Cirugía para el nacimiento de un bebé a través de una incisión en el abdomen y el útero de la madre.',
            'Dr. Roberto Morales, Dr. Silvia Díaz', 
            'María Antonieta', 
            'Medio', 
            '2024-06-25 10:00:00', 
            'Paciente con antecedentes de parto complicado.', 
            default,
            'Valoración preoperatoria completa, paciente en condiciones adecuadas.', 
            'Programada', 
            'Instrumental quirúrgico, Equipo de monitoreo fetal', 
            'Sala de partos', 
            NOW()
        ),
			(	DEFAULT,
            'Ortopédica', 
            'Reemplazo de Tobillo', 
            'Cirugía para reemplazar una articulación de rodilla dañada con una prótesis.',
            'Dr. Juan Diego, Dr. Ana Rivera', 
            'Brayan Gutierrez', 
            'Alto', 
            '2024-06-20 09:00:00', 
            'Paciente con antecedentes de artritis severa.', 
            default,
            'Valoración preoperatoria completa, paciente en condiciones adecuadas.', 
            'Programada', 
            'Prótesis de rodilla, Instrumental quirúrgico', 
            'Quirófano 2', 
            NOW()
        ),
        (	DEFAULT,
            'Cardíaca', 
            'Bypass Coronario', 
            'Cirugía para redirigir la sangre alrededor de una arteria coronaria bloqueada o parcialmente bloqueada.',
            'Dr. Carlos Ruiz, Dr. María Fernández', 
            'Lucía Gómez', 
            'Alto', 
            '2024-07-15 08:00:00',
            'Paciente con antecedentes de enfermedad coronaria.', 
            default,
            'Valoración preoperatoria completa, riesgo elevado pero aceptable.', 
            'Programada', 
            'Bypass, Instrumental quirúrgico', 
            'Quirófano 3', 
            NOW()  
        ),
        (	DEFAULT,
            'Neurológica', 
            'Resección de Tumor Cerebral', 
            'Cirugía para remover un tumor localizado en el lóbulo frontal del cerebro.',
            'Dr. Fernando López, Dr. Laura Sánchez', 
            'Estrella Ramos', 
            'Medio', 
            '2024-08-10 13:00:00',
            'Paciente con síntomas de presión intracraneal.', 
            default,
            'Valoración preoperatoria completa, paciente estable.', 
            'Programada', 
            'Instrumental neuroquirúrgico, Sistema de navegación', 
            'Quirófano 2', 
            NOW()
        ),
        (	DEFAULT,
            'Ginecológica', 
            'Cesárea', 
            'Cirugía para el nacimiento de un bebé a través de una incisión en el abdomen y el útero de la madre.',
            'Dr. Roberto Morales, Dr. Silvia Díaz', 
            'María Rodríguez', 
            'Medio', 
            '2024-06-25 10:00:00', 
            'Paciente con antecedentes de parto complicado.', 
            default,
            'Valoración preoperatoria completa, paciente en condiciones adecuadas.', 
            'Programada', 
            'Instrumental quirúrgico, Equipo de monitoreo fetal', 
            'Sala de partos', 
            NOW()
        ),
        (	DEFAULT,
            'Oftalmológica', 
            'Cirugía de Cataratas', 
            'Procedimiento para remover el cristalino del ojo cuando se ha vuelto opaco.',
            'Dr. Elena Gómez, Dr. Martín Pérez', 
            'Ana López', 
            'Bajo', 
            '2024-06-18 11:00:00',
            'Paciente con visión borrosa debido a cataratas.', 
            default,
            'Valoración preoperatoria completa, paciente en buenas condiciones.', 
            'Programada', 
            'Lentes intraoculares, Instrumental quirúrgico', 
            'Sala de cirugía menor', 
            NOW()
        ),
         (	DEFAULT,
            'Neurológica', 
            'Resección de Tumor Cerebral', 
            'Cirugía para remover un tumor localizado en el lóbulo frontal del cerebro.',
            'Dr. Fernando López, Dr. Laura Sánchez', 
            'Raúl Torres', 
            'Medio', 
            '2024-08-10 13:00:00',
            'Paciente con síntomas de presión intracraneal.', 
            default,
            'Valoración preoperatoria completa, paciente estable.', 
            'Programada', 
            'Instrumental neuroquirúrgico, Sistema de navegación', 
            'Quirófano 2', 
            NOW()
        );

        UPDATE tbb_cirugias 
        SET nivel_urgencia = 'Alto', paciente = 'Ana López'
        WHERE paciente = 'Ana López';
		UPDATE tbb_cirugias 
        SET nivel_urgencia = 'Bajo', paciente = 'Ana López'
        WHERE paciente = 'Ana López';

        DELETE FROM tbb_cirugias 
        WHERE paciente = 'Lucía Gómez';
        DELETE FROM tbb_cirugias 
        WHERE paciente = 'Raúl Torres';
    ELSE
        SELECT "La contraseña es incorrecta, no puedo mostrarte el estatus de la Base de Datos" AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_citas_medicas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`janeth.ahuacatitla`@`%` PROCEDURE `sp_poblar_citas_medicas`(v_password VARCHAR(20))
BEGIN
	
	IF v_password = "1234" THEN
    
    
    
	INSERT INTO tbb_citas_medicas (Tipo, Paciente_ID, Personal_medico_ID, Servicio_Medico_ID,
    Espacio_ID, Fecha_Programada, Estatus, Observaciones)
	VALUES
	('Revisión',  5, 1,1, 3, '2024-08-15 10:00:00','Programada', 'Sin Observaciones'),
	('Diagnóstico',  5, 2,5, 3, '2024-07-18 10:20:00', 'En proceso','Sin Observaciones'),
	('Seguimiento', 6, 3, 1,5, '2024-06-30 11:00:00', 'Atendida',  'El paciente se encuentra estable'),
	('Revisión',  8, 3, 1,5, '2024-05-02 09:45:00', 'Cancelada','Sin Observaciones'),
    ('Diagnóstico', 8,3, 1, 6, '2024-07-01 09:00:00','Atendida', 
    'Se diagnosticó en el paciente una gripa estacionaria, se le asigno tratamiento.');
    
	UPDATE tbb_citas_medicas 
    SET Fecha_Programada = '2024-08-30 09:30:00', Estatus = "Reprogramada" WHERE ID = 1;
    
	DELETE FROM tbb_citas_medicas WHERE ID=4;
    
	ELSE
	SELECT "La contraseña es incorrecta, no puedo realizar la operación" AS ErrorMessage;
	END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_consumibles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`daniela.aguilar`@`%` PROCEDURE `sp_poblar_consumibles`(IN v_password VARCHAR(20))
BEGIN
    DECLARE v_estatus VARCHAR(20) DEFAULT 'Activo';
    
    IF v_password = 'xYz$123' THEN
        -- Insertar en la tabla tbc_consumibles
        INSERT INTO tbc_consumibles 
        (nombre, descripcion, tipo, departamento, cantidad_existencia, detalle, fecha_registro, fecha_actualizacion, estatus, observaciones, espacio_medico) 
        VALUES 
        ('Guantes', 'Guantes latex', 'Proteccion', 'Almacen', 500, 'Caja de 100 guantes', NOW(), NOW(), 1, 'Revisar antes de entrar', 'Emergencias'),
        ('Gasas', 'Gasas estériles', 'Material Médico', 'Almacen', 1000, 'Paquete de 50 gasas', NOW(), NOW(), 1, 'Mantener en ambiente seco', 'Urgencias'),
        ('Jeringas', 'Jeringas desechables', 'Material Médico', 'Almacen', 800, 'Caja de 100 jeringas', NOW(), NOW(), 1, 'Manipular con cuidado', 'Consultas Externas'),
        ('Vendas', 'Vendas elásticas', 'Material Médico', 'Almacen', 1200, 'Rollo de 10 metros', NOW(), NOW(), 1, 'Utilizar para vendajes compresivos', 'Emergencias'),
        ('Analgésico', 'Medicamento', 'Farmacia', 'Estantería A', 500, 'Tabletas para alivio del dolor moderado a severo', NOW(), NOW(), 1, 'Mantener en lugar fresco y seco', 'Consultas Externas');

        -- Actualizar un registro en la tabla tbc_consumibles
        UPDATE tbc_consumibles 
        SET cantidad_existencia = 600, fecha_actualizacion = NOW() 
        WHERE nombre = 'Guantes';

        -- Eliminar un registro en la tabla tbc_consumibles
        DELETE FROM tbc_consumibles 
        WHERE nombre = 'Analgésico';

        -- Determinar el estatus para la bitácora
    ELSE
        SELECT 'La contraseña es incorrecta' AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_dispensacion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`Cristian.Ojeda`@`%` PROCEDURE `sp_poblar_dispensacion`(IN v_password VARCHAR(20))
BEGIN
    IF v_password = 'xYz$123' THEN
        -- Insertar registros predefinidos
        INSERT INTO tbd_dispensaciones 
            (RecetaMedica_id, PersonalMedico_id, Departamento_id, Solicitud_id, Estatus, Tipo, TotalMedicamentosEntregados, Total_costo, Fecha_registro)
            VALUES 
            (NULL, 2, 3, 4, 'Abastecida', 'Publica', 10, 100.00, NOW()),
            (2, 3, 4, NULL, 'Parcialmente abastecida', 'Privada', 5, 50.00, NOW());

        -- Actualizar un registro específico predefinido
        UPDATE tbd_dispensaciones
        SET Estatus = 'Parcialmente abastecida', 
            Tipo = 'Mixta', 
            TotalMedicamentosEntregados = 20, 
            Total_costo = 200.00
            WHERE id = 1;
        
        -- Eliminar un registro específico predefinido
        DELETE FROM tbd_dispensaciones 
        WHERE id = 2;
    
    ELSE
        SELECT 'La contraseña es incorrecta' AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_espacios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`bruno.lemus`@`%` PROCEDURE `sp_poblar_espacios`(v_password VARCHAR(20))
BEGIN
	DECLARE id_espacio_superior_1 INT DEFAULT 0;
    DECLARE id_espacio_superior_2 INT DEFAULT 0;
    IF v_password = "xYz$123" THEN
        -- Insertar varios registros en la tabla tbd_espacio
        
        
        -- INSERTAMOS EL EDIFICIO 1 - Medicina General
        INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus) VALUES
        ('Edificio', 'Medicina General',1 ,NULL,DEFAULT, DEFAULT);
        SET id_espacio_superior_1= last_insert_id();
		
        -- Espacios de Nivel 2 
       INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus) VALUES
        ('Piso', 'Planta Baja',56 ,id_espacio_superior_1,DEFAULT,DEFAULT);
        SET id_espacio_superior_2= last_insert_id();
        -- Espacios de Nivel 3
        INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus) VALUES
        ('Consultorio', 'A-101',11 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Consultorio', 'A-102',11 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Consultorio', 'A-103',11 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Consultorio', 'A-104',17 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Consultorio', 'A-105',17 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Quirófano', 'A-106',16 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Quirófano', 'A-107',16 ,id_espacio_superior_2,DEFAULT, DEFAULT), 
        ('Sala de Espera', 'A-108',16 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Sala de Espera', 'A-109',16 ,id_espacio_superior_2,DEFAULT, DEFAULT);
           
             
        INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus) VALUES
        ('Piso', 'Planta Alta',56, id_espacio_superior_1,DEFAULT, DEFAULT);
        SET id_espacio_superior_2= last_insert_id();
        INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus) VALUES
        ('Habitación', 'A-201',11 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Habitación', 'A-202',11 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Habitación', 'A-203',11 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Habitación', 'A-204',11 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Habitación', 'A-205',11 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Laboratorio', 'A206',23 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Capilla', 'A-207',56 ,id_espacio_superior_2,DEFAULT, DEFAULT), 
        ('Recepción', 'A-208',1 ,id_espacio_superior_2,DEFAULT, DEFAULT);
        
        /*
        -- INSERTAMOS EL EDIFICIO 2 - Medicina de Especialidad
        INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Estatus, Capacidad, Espacio_Superior_ID) VALUES
        ('Oficina', 'Oficina Quirúrgica', 'Recursos Humanos', 'Activo', 10, 'Piso 3, Edificio Principal');
        -- INSERTAMOS EL EDFICIO 3 -  Areas Administrativas
        INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Estatus, Capacidad, Espacio_Superior_ID) VALUES
        ('Oficina', 'Oficina Quirúrgica', 'Recursos Humanos', 'Activo', 10, 'Piso 3, Edificio Principal');
        */
      


        -- Realizar algunas actualizaciones o eliminaciones si es necesario
        UPDATE tbc_espacios SET Estatus= 'En remodelación' WHERE nombre = 'A-105';
        UPDATE tbc_espacios SET Capacidad = 80 WHERE nombre = 'A-109';
        
        DELETE FROM tbc_espacios WHERE nombre = 'A-207';
        

    ELSE
        SELECT "La contraseña es incorrecta, no puedo proceder con la inserción de registros" AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_estudios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`Juan.cruz`@`%` PROCEDURE `sp_poblar_estudios`(v_password VARCHAR(60))
BEGIN
	IF v_password="123" THEN
        -- Insertar datos en la tabla tbc_estudios
        INSERT INTO tbc_estudios (
            Tipo,
            Nivel_Urgencia,
            SolicitudID,
            ConsumiblesID,
            Estatus,
            Total_Costo,
            Dirigido_A,
            Observaciones,
            Fecha_Registro,
            Fecha_Actualizacion,
            ConsumibleID
        ) VALUES (
            'MRI',
            'Alta',
            23,
            12,
            'Completado',
            500.00,
            'Dr. Juan Pérez',
            'Resultados del primer estudio',
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            2
        );
        
        INSERT INTO tbc_estudios (
            Tipo,
            Nivel_Urgencia,
            SolicitudID,
            ConsumiblesID,
            Estatus,
            Total_Costo,
            Dirigido_A,
            Observaciones,
            Fecha_Registro,
            Fecha_Actualizacion,
            ConsumibleID
        ) VALUES (
            'Ultrasonido',
            'Media',
            11,
            11,
            'Completado',
            300.00,
            'Dr. Ana Gómez',
            'Resultados del segundo estudio',
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            11
        );

        -- Actualizar datos en la tabla tbc_estudios
        UPDATE tbc_estudios 
        SET 
            Tipo = 'Ecografía',
            Nivel_Urgencia = 'Baja',
            SolicitudID = 12,
            ConsumiblesID = 459,
            Estatus = 'Completado',
            Total_Costo = 180.00,
            Dirigido_A = 'Dr. Laura Martínez',
            Observaciones = 'Sin observaciones',
            Fecha_Actualizacion = CURRENT_TIMESTAMP,
            ConsumibleID = 793
        WHERE 
            ID = 1;

        -- Eliminar datos de la tabla tbc_estudios
        DELETE FROM tbc_estudios 
        WHERE ID = 1;

    ELSE 
        SELECT "La contraseña es incorrecta, no se puede realizar modificación en la tabla Resultados Estudios" AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_expedientes_clinicos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`arturo.aguilar`@`%` PROCEDURE `sp_poblar_expedientes_clinicos`(v_password varchar(20))
BEGIN
	if v_password = "1234" then
		
        INSERT INTO tbb_personas 
(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
VALUES
('Sra.', 'María', 'López', 'Martínez', 'LOMJ850202PDFRPL01', 'F', 'A+', '1985-02-02', b'1', NOW(), NULL),
('C.', 'Ana', 'Hernández', 'Ruiz', 'HERA900303HDFRIL01', 'F', 'B+', '1990-03-03', b'1', NOW(), NULL),
('Dr.', 'Carlos', 'García', 'Rodríguez', 'GARC950404NDFRRL06', 'M', 'AB+', '1995-04-04', b'1', NOW(), NULL),
('Lic.', 'Laura', 'Martínez', 'Gómez', 'MALG000505TDFRRL07', 'F', 'O-', '2000-05-05', b'1', NOW(), NULL);

        
        
			insert into tbd_expedientes_clinicos values 
			(1,1,'Asma bronquial','Alergia a la penicilina','Alzheimer en abuelo materno','Todo bien','Gripe','Mas vitaminas',default, default, null),
			(3,2,'Hipertensión arterial','Cirugía de apéndice a los 12 años.','Enfermedad cardíaca coronaria en padre y tíos paternos.','Frecuencia Cardiaca baja','Sano','Hidratarse más',default, default, null),
			(4,3,'Hepatitis B previa','Historial de viajes a países tropicales','Cáncer colorrectal en primo hermano','Frecuencia Reepiratoria baja','En buenas condiciones','Necesita mas actividad fisica',default, default, null),
			(default,4,'Artritis reumatoide','Ausencia de alergias conocidas a medicamentos.','Asma en hermano menor.','Presion baja','Salud Optima','No come bien',default, default, null);
            
			update tbb_expedientes_clinicos set Notas_Medicas = 'Necesita paracetamol' where Interrogatorio_sistemas = 'Presion baja';
			update tbb_expedientes_clinicos set estatus = b'0' where Interrogatorio_sistemas = 'Frecuencia Reepiratoria baja';
			
			delete from tbb_expedientes_clinicos where Interrogatorio_sistemas = 'Frecuencia Cardiaca baja';
		else
			select "La contraseña es incorrecta, no puedo mostrarte el estatus de la Base de Datos" as ErrorMessage;
		end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_horarios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`DiegoOliver`@`%` PROCEDURE `sp_poblar_horarios`()
BEGIN
    DECLARE contador INT DEFAULT 1;
    
    WHILE contador <= 5 DO
        INSERT INTO tbd_horarios (empleado_id, nombre, especialidad, dia_semana, hora_inicio, hora_fin, turno, nombre_departamento, nombre_sala) 
        VALUES (contador, 
                CONCAT('Doctor ', contador), 
                CONCAT('Especialidad ', contador), 
                'Lunes', 
                '08:00:00', 
                '16:00:00', 
                'Matutino', 
                CONCAT('Departamento ', contador % 3 + 1), 
                CONCAT('Sala ', contador % 2 + 1));
                
        SET contador = contador + 1;
    END WHILE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_lotes_medicamentos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`myriam.valderrabano`@`%` PROCEDURE `sp_poblar_lotes_medicamentos`(v_password VARCHAR(20))
BEGIN
	IF v_password = "xYz$123" THEN
        -- Insertar registros en la tabla tbd_lotes_medicamentos
        INSERT INTO tbd_lotes_medicamentos (Medicamento_ID, Personal_Medico_ID, Clave, Estatus, Costo_Total, Cantidad, Ubicacion)
        VALUES
        (1, 101, 'ABC123', 'Reservado', 100.00, 10, 'Almacen A'),
        (2, 102, 'DEF456', 'En transito', 200.00, 20, 'Almacen B'),
        (3, 103, 'GHI789', 'Recibido', 300.00, 30, 'Almacen C');
        -- (4, 104, 'JKL012', 'Rechazado', 400.00, 40, 'Almacen D'),
        -- (5, 105, 'MNO345', 'Reservado', 500.00, 50, 'Almacen E');

        -- Actualización 1
        UPDATE tbd_lotes_medicamentos 
        SET Estatus = 'Rechazado', Ubicacion = 'Almacén W' 
        WHERE ID = 2;

        -- Actualización 2
        UPDATE tbd_lotes_medicamentos 
        SET Estatus = 'Reservado', Cantidad = 15 
        WHERE ID = 3;

        -- Eliminación
        DELETE FROM tbd_lotes_medicamentos 
        WHERE ID = 3;

    ELSE
        SELECT "La contraseña es incorrecta, no puedo mostrarte el estatus de llenado de la Base de datos" AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_medicamentos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`Cristian.Ojeda`@`%` PROCEDURE `sp_poblar_medicamentos`(IN v_password VARCHAR(20))
BEGIN
 IF v_password = 'xYz$123' THEN
  -- Inserción de cinco registros reales
    INSERT INTO tbc_medicamentos (Nombre_comercial, Nombre_generico, Via_administracion, Presentacion, Tipo, Cantidad, Volumen)
    VALUES
    ('Tylenol', 'Paracetamol', 'Oral', 'Comprimidos', 'Analgesicos', 100, 0.0),
    ('Amoxil', 'Amoxicilina', 'Oral', 'Capsulas', 'Antibioticos', 50, 0.0),
    ('Zoloft', 'Sertralina', 'Oral', 'Comprimidos', 'Antidepresivos', 200, 0.0),
    ('Claritin', 'Loratadina', 'Oral', 'Grageas', 'Antihistaminicos', 150, 0.0),
    ('Advil', 'Ibuprofeno', 'Oral', 'Comprimidos', 'Antiinflamatorios', 300, 0.0);

    -- Actualización de uno de los registros
    UPDATE tbc_medicamentos
    SET Cantidad = 120, Volumen = 10.0, Fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE Nombre_comercial = 'Tylenol';

    -- Eliminación de uno de los registros
    DELETE FROM tbc_medicamentos
    WHERE Nombre_comercial = 'Amoxil';
  END IF;


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_nacimientos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`eli.aidan`@`%` PROCEDURE `sp_poblar_nacimientos`(v_password varchar(20))
BEGIN
	IF v_password = "1234" THEN
	insert into tbb_nacimientos values 
	(default, 'Juan Pérez', 'María Gómez', '80-120', b'1', 8, 'Observaciones aquí', 'M', NOW(), NULL),
	(default, 'Antonio López', 'Laura Martínez', '80-120', b'1', 8, 'Observaciones adicionales aquí', 'F', NOW(), NULL),
	(default, 'Carlos Rodríguez', 'Ana Sánchez', '80-120', b'1', 9, 'Observaciones adicionales aquí', 'M', NOW(), NULL),
	(default, 'Juan García', 'Carmen Ruiz', '80-120', b'1', 8, 'Observaciones adicionales aquí', 'F', NOW(), NULL),
	(default, 'Pedro López', 'Marta Pérez', '80-120', b'1', 7, 'Observaciones adicionales aquí', 'M', NOW(), NULL);

	update tbb_nacimientos set Padre = "Juan Pérez", Madre = "Claudia Sheinbaun" where Madre = "María Gómez";

	delete from tbb_nacimientos where Padre = "Pedro López";

ELSE
	select "La contraseña es incorrecta, no puedo mostrarte los nacimientos de la base de datos"  AS ErrorMessage;
END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_organos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`Alyn.Fosado`@`%` PROCEDURE `sp_poblar_organos`(
    IN p_password VARCHAR(255)
)
BEGIN
DECLARE v_correct_password VARCHAR(255) DEFAULT 'xYz$123';
    
    -- Verificamos la contraseña
    IF p_password = v_correct_password THEN
        
        -- Insertar registros de prueba
        INSERT INTO tbc_organos ( Nombre, Aparato_Sistema, Descripcion, Detalle_Organo_ID, Disponibilidad, Tipo, Fecha_Registro, Estatus)
        VALUES 
            ( 'Cerebro', 'Nervioso', 'Órgano principal del sistema nervioso.', 1, 'Disponible', 'Órgano Principal', CURRENT_TIMESTAMP(), b'1'),
            ( 'Corazón', 'Cardiovascular', 'Órgano muscular que bombea sangre a través del sistema circulatorio.', 2, 'Disponible', 'Órgano Principal', CURRENT_TIMESTAMP(), b'1'),
            ('Pulmón', 'Respiratorio', 'Órgano que permite la oxigenación de la sangre.', 3, 'Disponible', 'Órgano Principal', CURRENT_TIMESTAMP(), b'1'),
            ( 'Hígado', 'Digestivo', 'Órgano que procesa nutrientes y desintoxica sustancias.', 4, 'Disponible', 'Órgano Principal', CURRENT_TIMESTAMP(), b'1'),
            ( 'Riñón', 'Urinario', 'Órgano que filtra desechos de la sangre y produce orina.', 5, 'Disponible', 'Órgano Principal', CURRENT_TIMESTAMP(), b'1');
    
    ELSE
        -- Si la contraseña no es correcta, lanzamos un error
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Contraseña incorrecta';
        END IF;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_pacientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`justin.muñoz`@`%` PROCEDURE `sp_poblar_pacientes`(v_password varchar(10))
    DETERMINISTIC
BEGIN
IF v_password = "1234" then		
-- Insertamos los datos de la persona del primer paciente
INSERT INTO tbb_personas 
(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
VALUES
('Sra.', 'María', 'López', 'Martínez', 'LOMJ850202MDFRPL01', 'F', 'A+', '1985-02-02', b'1', NOW(), NULL);
INSERT INTO `tbb_pacientes` VALUES (last_insert_id(),NULL,'Sin Seguro','2009-03-17 17:31:00',default,'Vivo',1,'2001-02-15 06:23:05',NULL);
-- Insertamos los datos de la persona del segundo paciente
INSERT INTO tbb_personas 
(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
VALUES
(NULL, 'Ana', 'Hernández', 'Ruiz', 'HERA900303HDFRRL01', 'F', 'B+', '1990-03-03', b'1', NOW(), NULL);
INSERT INTO `tbb_pacientes` VALUES (last_insert_id(),NULL,'Sin Seguro','2019-05-01 13:15:29',default,'Vivo',1,'2020-06-28 18:46:37',NULL);
-- Insertamos los datos de la persona del tercer paciente
INSERT INTO tbb_personas 
(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
VALUES
('Dr.', 'Carlos', 'García', 'Rodríguez', 'GARC950404HDFRRL06', 'M', 'AB+', '1995-04-04', b'1', NOW(), NULL);
INSERT INTO `tbb_pacientes` VALUES (last_insert_id(),'G9OA6QW29V8DVXS','Seguro Popular','2024-02-16 13:10:48',default,'Vivo',1,'2024-02-18 16:05:14',NULL);
-- Insertamos los datos de la persona del cuarto paciente
INSERT INTO tbb_personas 
(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
VALUES
('Lic.', 'Laura', 'Martínez', 'Gómez', 'MALG000505MDFRRL07', 'F', 'O-', '2000-05-05', b'1', NOW(), NULL);
INSERT INTO `tbb_pacientes` VALUES (last_insert_id(),"12254185844-3",'Particular','2022-08-16 12:05:35',default,'Vivo',1,'2022-08-16 11:50:00',NULL);

update tbb_pacientes set NSS = "JL4HVKXPI3PX999" where NSS = "G9OA6QW29V8DVXS";
delete from tbb_pacientes where NSS = "JL4HVKXPI3PX999";
    
    
    else
		select "La contraseña es incorrecta" as mensaje;
        end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_personal_medico` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`jonathan.ibarra`@`%` PROCEDURE `sp_poblar_personal_medico`(v_password varchar(20))
BEGIN
    IF v_password = 'xyz#$%' THEN
    
    START TRANSACTION;
		-- Inserta los datos de la persona antes de sus datos cómo empleado del Hospital
		INSERT INTO tbb_personas VALUES (DEFAULT, "Dr.", "Alejandro", "Barrera", "Fernández",
        "BAFA810525HVZLRR05", "M", "O+", "1981-05-25", DEFAULT, DEFAULT,NULL);
        -- Insertamos los datos médicos del empledo
        INSERT INTO tbb_personal_medico VALUES (last_insert_id(), 13, "25515487", "Médico","Pediatría", 
        "2012-08-22 08:50:25", "2015-09-16 09:10:52", NULL, 35000,DEFAULT,NULL);
        
        -- Inserta los datos de la persona antes de sus datos cómo empleado del Hospital
		INSERT INTO tbb_personas VALUES (DEFAULT, "Dra.", "María José", "Álvarez", "Fonseca",
        "ALFM900620MPLLNR2A", "F", "O-", "1990-06-20", DEFAULT, DEFAULT,NULL);
        -- Insertamos los datos médicos del empledo
        INSERT INTO tbb_personal_medico VALUES (last_insert_id(), 11, "11422587", "Médico",NULL, 
        "2018-05-10 08:50:25", "2018-05-10 09:10:52", NULL, 10000,DEFAULT,NULL);
        
        -- Inserta los datos de la persona antes de sus datos cómo empleado del Hospital
		INSERT INTO tbb_personas VALUES (DEFAULT, "Dr.", "Alfredo", "Carrasco", "Lechuga",
        "CALA710115HCSRCL25", "M", "AB-", "1971-01-15", DEFAULT, DEFAULT,NULL);
        -- Insertamos los datos médicos del empledo
        INSERT INTO tbb_personal_medico VALUES (last_insert_id(), 1, "3256884", "Administrativo",NULL, 
        "2000-01-01 11:50:25", "2000-01-02 09:00:00", NULL, 40000,DEFAULT,NULL);
        
        -- Inserta los datos de la persona antes de sus datos cómo empleado del Hospital
		INSERT INTO tbb_personas VALUES (DEFAULT, "Lic.", "Fernanda", "García", "Méndez",
        "ABCD", "N/B", "A+", "1995-05-10", DEFAULT, DEFAULT,NULL);
        -- Insertamos los datos médicos del empledo
        INSERT INTO tbb_personal_medico VALUES (last_insert_id(), 9, "1458817", "Apoyo",NULL, 
        "2008-01-01 11:51:25", "2008-01-02 19:00:00", NULL, 8000,DEFAULT,NULL);
        
        -- Actualizamos el salario del director general
        UPDATE tbb_personal_medico SET salario= 45000 WHERE cedula_profesional="3256884";
         
		-- Eliminamos a un empleado
        DELETE FROM tbb_personal_medico WHERE cedula_profesional=1458817;
	
    COMMIT;
    
/*INSERT INTO tbb_personal_medico (Persona_ID, Departamento_ID, Especialidad, Tipo, 
Cedula_Profesional, Fecha_Contratacion, Salario, Fecha_Actualizacion) 
VALUES (4, 4, 'Dermatología', 'Médico Especialista', 'JKLM112233', '2024-06-06 13:00:00', 8000.00, NOW());

-- Insertar un quinto registro de personal médico
INSERT INTO tbb_personal_medico (Persona_ID, Departamento_ID, Especialidad, Tipo, 
Cedula_Profesional, Fecha_Contratacion, Salario, Fecha_Actualizacion) 
VALUES (5, 5, 'Oftalmología', 'Médico General', 'NOPQ445566', '2024-06-06 14:00:00', 6500.00, NOW());

INSERT INTO tbb_personal_medico (Persona_ID, Departamento_ID, Especialidad, Tipo,
 Cedula_Profesional, Fecha_Contratacion, Salario, Fecha_Actualizacion) 
VALUES (1, 3, 'Cardiología', 'Médico Residente', 
'ABCD123456', '2024-06-06 10:00:00', 5000.00, NOW());

-- Insertar otro registro de personal médico
INSERT INTO tbb_personal_medico (Persona_ID, Departamento_ID, Especialidad, Tipo,
 Cedula_Profesional, Fecha_Contratacion, Salario, Fecha_Actualizacion) 
VALUES (2, 2, 'Pediatría', 'Médico Titular', 
'WXYZ987654', '2024-06-06 11:00:00', 7000.00, NOW());

-- Insertar un tercer registro de personal médico
INSERT INTO tbb_personal_medico (Persona_ID, Departamento_ID, Especialidad, Tipo, 
Cedula_Profesional, Fecha_Contratacion, Salario, Fecha_Actualizacion) 
VALUES (3, 1, 'Ginecología', 'Médico Adjunto', 'FGHJ456789', '2024-06-06 12:00:00', 6000.00, NOW());

UPDATE tbb_personal_medico 
SET Salario = 5500.00, Fecha_Actualizacion = NOW() 
WHERE ID = 1;

-- Actualizar el estatus del personal médico con Cedula_Profesional 'WXYZ987654'
UPDATE tbb_personal_medico 
SET Estatus = 'Inactivo', Fecha_TerminacionContrato = NOW(), Fecha_Actualizacion = NOW() 
WHERE Cedula_Profesional = 'WXYZ987654';

-- Eliminar el registro de personal médico con ID 3
DELETE FROM tbb_personal_medico 
WHERE ID = 3;

-- Eliminar el personal médico con Cedula_Profesional 'FGHJ456789'
DELETE FROM tbb_personal_medico 
WHERE Cedula_Profesional = 'FGHJ456789';
*/


    ELSE
        -- Mensaje de error si la contraseña es incorrecta
        SELECT "La contraseña es incorrecta, no puedo insertar datos en la Base de Datos" AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_personas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`jose.gomez`@`%` PROCEDURE `sp_poblar_personas`(v_password varchar(20))
BEGIN
if v_password="1234" then
INSERT INTO tbb_personas 
(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
VALUES
('Sra.', 'María', 'López', 'Martínez', 'LOMJ850202MDFRPL02', 'F', 'A+', '1985-02-02', b'1', NOW(), NULL),
('C.', 'Ana', 'Hernández', 'Ruiz', 'HERA900303HDFRRL03', 'F', 'B+', '1990-03-03', b'1', NOW(), NULL),
('Dr.', 'Carlos', 'García', 'Rodríguez', 'GARC950404HDFRRL04', 'M', 'AB+', '1995-04-04', b'1', NOW(), NULL),
('Lic.', 'Laura', 'Martínez', 'Gómez', 'MALG000505MDFRRL05', 'F', 'O-', '2000-05-05', b'1', NOW(), NULL),
('C.', 'Luis', 'Pérez', 'Sánchez', 'PESL010606HDFRRL06', 'M', 'A-', '2001-06-06', b'1', NOW(), NULL),
('C.', 'Mónica', 'López', 'Hernández', 'LOHM020707MDFRRL07', 'F', 'B-', '2002-07-07', b'1', NOW(), NULL),
('C.', 'Pedro', 'Gómez', 'Pérez', 'GOPP030808HDFRRL08', 'M', 'AB-', '2003-08-08', b'1', NOW(), NULL),
('C.', 'Sofía', 'Ruiz', 'López', 'RULS040909HDFRRL09', 'F', 'O+', '2004-09-09', b'1', NOW(), NULL),
('C.', 'José', 'Sánchez', 'García', 'SAGJ051010HDFRRL10', 'M', 'A+', '2005-10-10', b'1', NOW(), NULL);

UPDATE tbb_personas SET Primer_Apellido = 'Hernández', Estatus = b'0' WHERE ID = 1;

DELETE FROM tbb_personas where ID=2;
	 else
		select "La contraseña es incorrecta, no puedo mostrar el estatus de la Base de Datos" As ErrorMessage;
	end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_puestos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`jesus.rios`@`%` PROCEDURE `sp_poblar_puestos`(IN v_password VARCHAR(20))
BEGIN
    IF v_password = '1234' THEN
        -- Insertar puestos en la tabla tbc_puestos
        INSERT INTO tbc_puestos (Nombre, Descripcion, Salario, Turno, Creado, Modificado) VALUES 
        ('Médicos', 'Profesionales médicos que diagnostican y tratan a los pacientes', 5000.00, 'Mañana', NOW(), NOW()),
        ('Enfermeras', 'Proporcionan cuidados directos a los pacientes', 3000.00, 'Tarde', NOW(), NOW()),
        ('Técnicos de laboratorio', 'Realizan análisis clínicos y pruebas de laboratorio', 2500.00, 'Mañana', NOW(), NOW()),
        ('Técnicos radiológicos', 'Realizan estudios por imágenes como radiografías y resonancias', 2600.00, 'Tarde', NOW(), NOW()),
        ('Técnicos de farmacia', 'Ayudan en la dispensación y gestión de medicamentos', 2400.00, 'Mañana', NOW(), NOW()),
        ('Asistentes médicos', 'Apoyan a los médicos en consultas y procedimientos', 2800.00, 'Mañana', NOW(), NOW()),
        ('Personal administrativo', 'Gestiona tareas administrativas y de recepción', 2200.00, 'Mañana', NOW(), NOW()),
        ('Personal de limpieza', 'Mantiene la limpieza y el orden en las instalaciones', 1800.00, 'Noche', NOW(), NOW()),
        ('Terapeutas ocupacionales', 'Ayudan a pacientes a recuperar habilidades para la vida diaria', 2700.00, 'Mañana', NOW(), NOW()),
        ('Fisioterapeutas', 'Realizan terapias físicas para la rehabilitación de pacientes', 2800.00, 'Tarde', NOW(), NOW()),
        ('Logopedas', 'Especializados en trastornos del habla y lenguaje', 2600.00, 'Mañana', NOW(), NOW()),
        ('Administradores de salud', 'Gestionan operaciones y recursos en el ámbito de la salud', 3500.00, 'Tarde', NOW(), NOW()),
        ('Cocineros', 'Preparan comidas nutritivas para pacientes y personal', 2000.00, 'Mañana', NOW(), NOW()),
        ('Dietistas', 'Planifican dietas personalizadas según necesidades de los pacientes', 2300.00, 'Tarde', NOW(), NOW()),
        ('Personal de seguridad', 'Garantizan la seguridad y el orden dentro del hospital', 2100.00, 'Noche', NOW(), NOW()),
        ('Personal de mantenimiento', 'Realizan mantenimiento preventivo y correctivo de instalaciones', 1900.00, 'Tarde', NOW(), NOW()),
        ('Investigadores médicos', 'Conductores de investigación clínica y científica', 3800.00, 'Día', NOW(), NOW()),
        ('Educadores médicos', 'Imparten conocimientos y formación a profesionales de la salud', 3200.00, 'Mañana', NOW(), NOW()),
        ('Voluntarios', 'Ofrecen su tiempo y servicios de manera voluntaria', 0.00, 'Noche', NOW(), NOW());

        -- Actualizar un puesto específico
        -- Ejemplo: Actualizar el salario del puesto con nombre 'Médicos'
        UPDATE tbc_puestos
        SET Salario = 5200.00, Modificado = NOW()
        WHERE Nombre = 'Médicos';

        -- Eliminar un puesto específico
        -- Ejemplo: Eliminar el puesto con nombre 'Educadores médicos'
        DELETE FROM tbc_puestos
        WHERE Nombre = 'Educadores médicos';
    ELSE
        SELECT "La contraseña es incorrecta, no puedo mostrar el estatus de la Base de Datos" AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_puestos_departamentos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`jesus.rios`@`%` PROCEDURE `sp_poblar_puestos_departamentos`(IN v_password VARCHAR(20))
BEGIN
    IF v_password = '1234' THEN
        -- Inserción de cinco registros reales
        INSERT INTO tbd_puestos_departamentos (Nombre, Descripcion, Salario, Turno, DepartamentoID)
        VALUES
        ('Medico General', 'Responsable de consultas generales', 50000.00, 'Mañana', 1),
        ('Enfermero', 'Responsable de cuidado de pacientes', 30000.00, 'Tarde', 2),
        ('Cirujano', 'Responsable de realizar cirugías', 70000.00, 'Noche', 3),
        ('Pediatra', 'Especialista en cuidado de niños', 55000.00, 'Mañana', 1),
        ('Radiologo', 'Responsable de estudios de imagen', 60000.00, 'Tarde', 4);

        -- Actualización de uno de los registros
        UPDATE tbd_puestos_departamentos
        SET Salario = 52000.00, Modificado = CURRENT_TIMESTAMP
        WHERE Nombre = 'Medico General';

        -- Eliminación de uno de los registros
        DELETE FROM tbd_puestos_departamentos
        WHERE Nombre = 'Enfermero';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_recetas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`marvin.tolentino`@`localhost` PROCEDURE `sp_poblar_recetas`(v_password varchar(20))
BEGIN
IF v_password = "141002" THEN
	SET SQL_SAFE_UPDATES = 0;

	delete from tbd_recetas_medicas;
	alter table tbd_recetas_medicas auto_increment = 1;
	INSERT INTO tbd_recetas_medicas VALUES 
	(1,'Juan Pérez',
    35, 'Dr. García',
    '2024-06-06', '2024-06-06',
    'Gripe común', 'Paracetamol, Ibuprofeno',
    'Tomar una tableta de Paracetamol cada 6 horas y una tableta de Ibuprofeno cada 8 horas durante 3 días.'),
    (2,'Mario López',
    55, 'Dr. Goku',
    '2024-05-04', '2024-06-06',
    'Hipertensión arterial', 'Losartán, Amlodipino', 
    'Tomar una tableta de Losartán y una tableta de Amlodipino diariamente antes del desayuno.'),
	(3,
    'María López', 45, 
    'Dr. Martínez', 
    '2024-06-05', '2024-06-06', 
    'Hipertensión arterial', 'Losartán, Amlodipino', 
    'Tomar una tableta de Losartán y una tableta de Amlodipino diariamente antes del desayuno.'),
    (4,
    'Yair Tolentino', 21, 
    'Dr. Jesus', 
    '2024-06-05', '2024-06-06', 
    'Sindrome de Dawn', 'Ibuprofeno, Aspirinas', 
    'Tomar una tableta de aspirina y una tableta de ibuprofeno antes de dormir'),
    (5,
	 'Ana García', 30,
	 'Dr. Rodríguez',
	 '2024-06-10', '2024-06-10',
	 'Infección de garganta',
	 'Amoxicilina, Ibuprofeno',
	 'Tomar una tableta de Amoxicilina cada 8 horas y una tableta de Ibuprofeno cada 6 horas durante 5 días.'),
	(6,
	 'Pedro Ramírez', 40,
	 'Dr. Gómez',
	 '2024-06-12', '2024-06-12',
	 'Diabetes tipo 2',
	 'Metformina, Glibenclamida',
	 'Tomar una tableta de Metformina y una tableta de Glibenclamida antes de cada comida principal.'),
	(7,
	 'Luisa Martínez', 50,
	 'Dr. Sánchez',
	 '2024-06-14', '2024-06-14',
	 'Osteoartritis',
	 'Paracetamol, Meloxicam',
	 'Tomar una tableta de Paracetamol cada 6 horas y una tableta de Meloxicam diariamente.'),
	(8,
	 'Carlos Hernández', 60,
	 'Dr. Pérez',
	 '2024-06-15', '2024-06-15',
	 'Dolor de espalda crónico',
	 'Ibuprofeno, Naproxeno',
	 'Tomar una tableta de Ibuprofeno cada 8 horas y una tableta de Naproxeno cada 12 horas.'),
	(9,
	 'Laura Ramírez', 25,
	 'Dr. Díaz',
	 '2024-06-16', '2024-06-16',
	 'Migraña',
	 'Sumatriptán, Paracetamol',
	 'Tomar una tableta de Sumatriptán al inicio de la migraña y una tableta de Paracetamol cada 6 horas si persiste el dolor.'),
	(10,
	 'Javier Pérez', 48,
	 'Dr. Ramírez',
	 '2024-06-18', '2024-06-18',
	 'Gastritis crónica',
	 'Omeprazol, Ranitidina',
	 'Tomar una cápsula de Omeprazol antes del desayuno y una tableta de Ranitidina antes de la cena.');
		
    
	UPDATE tbd_recetas_medicas SET paciente_nombre = 'Pedro González' WHERE id = 1;
    UPDATE tbd_recetas_medicas SET paciente_nombre = 'Marvin Perez' WHERE id = 2;
	UPDATE tbd_recetas_medicas SET medicamentos = 'Marihuanol, Clonazepan', diagnostico ='VIH' WHERE id = 2;
	UPDATE tbd_recetas_medicas SET indicaciones = 'Reposo' WHERE id = 3;
    UPDATE tbd_recetas_medicas SET medicamentos = 'Clonazepan, inyeccion letal', diagnostico ='VIH' WHERE id = 4;
    
		
	delete from tbd_recetas_medicas where id= 1;
    
else
	select "La contraseña es incorrecta"  AS ErrorMessage;
END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_recetas_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`marvin.tolentino`@`localhost` PROCEDURE `sp_poblar_recetas_1`(
    IN v_password VARCHAR(20),
    IN v_id_paciente INT UNSIGNED,
    IN v_id_medico INT UNSIGNED,
    IN v_num_recetas INT
)
BEGIN
    DECLARE v_fecha_cita DATETIME;
    DECLARE v_counter INT DEFAULT 0;

    IF v_password = "141002" THEN
        SET SQL_SAFE_UPDATES = 0;

        -- Limpiar la tabla antes de insertar nuevas recetas

        -- Insertar la cantidad especificada de recetas
        WHILE v_counter < v_num_recetas DO
            -- Generar una fecha aleatoria a partir del 2024
            SET v_fecha_cita = DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND() * 365) DAY);

            -- Insertar una receta
            INSERT INTO tbd_recetas_medicas 
            (fecha_cita, fecha_actualizacion, diagnostico, id_paciente, id_medico) 
            VALUES 
            (
                v_fecha_cita,  -- Fecha aleatoria a partir del 2024
				null,  -- Fecha de actualización
                generar_diagnosticos(),  -- Generar un diagnóstico dinámico
                v_id_paciente,  -- ID del paciente
                v_id_medico  -- ID del médico
            );

            -- Incrementar el contador
            SET v_counter = v_counter + 1;
        END WHILE;
        
        UPDATE tbd_recetas_medicas
        SET diagnostico = 'Viruela del mono'
        WHERE diagnostico =  'Gastritis';
	
        

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password incorrecto';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_recetas_detalles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`marvin.tolentino`@`localhost` PROCEDURE `sp_poblar_recetas_detalles`(
    IN v_password VARCHAR(20),
    IN v_id_receta INT UNSIGNED,
    IN v_num_recetas INT
)
BEGIN
    DECLARE v_counter INT DEFAULT 0;

    IF v_password = "141002" THEN
        SET SQL_SAFE_UPDATES = 0;

        -- Insertar la cantidad especificada de recetas
        WHILE v_counter < v_num_recetas DO
            -- Generar una fecha aleatoria a partir del 2024
            -- Insertar una receta
            INSERT INTO tbd_recetas_detalles
            (id_receta, observaciones, recomendaciones) 
            VALUES 
            (
				v_id_receta,  -- ID del paciente
                generar_observaciones(),  -- Generar un diagnóstico dinámico
				generar_indicaciones()
            );

            -- Incrementar el contador
            SET v_counter = v_counter + 1;
        END WHILE;

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password incorrecto';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_recetas_medicamentos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`marvin.tolentino`@`localhost` PROCEDURE `sp_poblar_recetas_medicamentos`(
    IN v_password VARCHAR(20),
    IN v_id_receta INT UNSIGNED,
    IN v_id_medicamento INT UNSIGNED
)
BEGIN

    IF v_password = "141002" THEN
        SET SQL_SAFE_UPDATES = 0;

        INSERT INTO tbd_receta_medicamentos (id_receta, id_medicamento, cantidad, indicaciones) 
        VALUES (
            v_id_receta,  -- ID de la receta
            v_id_medicamento,
			(SELECT cantidad FROM tbc_medicamentos WHERE ID = v_id_medicamento),   -- Cantidad proporcionada como parámetro
            generar_indicaciones_medicamentos()  -- Generar indicaciones dinámicas
        );

    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_resultados_estudios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`armando.carrasco`@`%` PROCEDURE `sp_poblar_resultados_estudios`(v_password VARCHAR(60))
BEGIN
IF v_password="xYz$123" THEN
        INSERT INTO tbd_resultados_estudios (Paciente_ID, Personal_Medico_ID, Estudio_ID, Folio, Resultados, Observaciones, Estatus)
        VALUES (23, 12, 2, '1234', 'Resultados del primer estudio', 'Observaciones', 'Completado');
        INSERT INTO tbd_resultados_estudios (Paciente_ID, Personal_Medico_ID, Estudio_ID, Folio, Resultados, Observaciones, Estatus)
        VALUES (11, 11, 11, '12444', 'Resultados del segundo estudio', 'Observaciones', 'Completado');
        INSERT INTO tbd_resultados_estudios (Paciente_ID, Personal_Medico_ID, Estudio_ID, Folio, Resultados, Observaciones, Estatus)
        VALUES (8, 15, 5, '5678', 'Resultados del tercer estudio', 'Observaciones', 'Pendiente');
        INSERT INTO tbd_resultados_estudios (Paciente_ID, Personal_Medico_ID, Estudio_ID, Folio, Resultados, Observaciones, Estatus)
        VALUES (17, 10, 3, '98765', 'Resultados del cuarto estudio', 'Observaciones', 'En Proceso');
        INSERT INTO tbd_resultados_estudios (Paciente_ID, Personal_Medico_ID, Estudio_ID, Folio, Resultados, Observaciones, Estatus)
        VALUES (9, 18, 8, '555', 'Resultados del quinto estudio', 'Observaciones', 'Aprobado');
        INSERT INTO tbd_resultados_estudios (Paciente_ID, Personal_Medico_ID, Estudio_ID, Folio, Resultados, Observaciones, Estatus)
        VALUES (14, 9, 7, '777', 'Resultados del sexto estudio', 'Observaciones', 'Rechazado');


UPDATE  tbd_resultados_estudios set Paciente_ID=12, Observaciones='Sin observaciones' where ID=1;
UPDATE  tbd_resultados_estudios set Paciente_ID=24, Observaciones='Sin observaciones' where ID=3;

delete from tbd_resultados_estudios where ID=1;

ELSE 
SELECT "La contraseña es incorrecta, no se puede realizar modificacion en la tabla Resultados Estudios" AS ErrorMessage;
end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_roles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_roles`(v_password VARCHAR(20))
BEGIN  
	
    IF v_password = "xYz$123" THEN
		
		INSERT INTO tbc_roles VALUES (default, 'Admin', 'Usuario Administrador del Sistema que permitira modificar datos críticos', default, default, null),
        (default, 'Direccion General', 'Usuario de la Máxima Autoridad del Hospital, que le permitirá acceder a módulos para el control y operacion del servicio del Hospital', default, default, null),
        (default, 'Paciente', 'Usuario que tendra acceso a consultar la información médica asociada a su salud', default, default, null),
        (default, 'Médico General', 'Usuario que tendra acceso a consultar y modificar la información de salud de los pacientes y sus citas médicas', default, default, null),
        (default, 'Médico Especialista', 'Usuario que tendrá a acceso consultar y modificar la información de salud de los pacientes específicos a una especialidad médica', default, default, null),
        (default, 'Enfermero', 'Usuario que apoya en la gestión y desarrollo de los servicios médico proporcionados a los pacientes.', default, default, null), 
        (default, 'Familiar del Paciente', 'Usuario que puede consultar, y verificar la información de un paciente en caso de que no este en capacidad o conciencia propia', default, default, null),
        (default, 'Paciente IMSS', 'Este usuario es de prueba para testear el borrado en bitacora', default, default, null);
        
        UPDATE tbc_roles SET nombre = 'Administrador' WHERE nombre = 'Admin';
        UPDATE tbc_roles set estatus = b'0' where nombre = 'Familiar del Paciente';
        
        DELETE FROM tbc_roles WHERE nombre= "Paciente IMSS";
        
    ELSE 
      SELECT "La contraseña es incorrecta, no puedo mostrarte el 
      estatus de la Base de Datos" AS ErrorMessage;
    
    END IF;
		

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_roles_usuarios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_roles_usuarios`(v_password VARCHAR(20))
BEGIN  
	
    IF v_password = "xYz$123" THEN
		
		INSERT INTO tbd_usuarios_roles (usuario_id, rol_id)
        VALUES 
        (1,4),(1,1), (2,3), (3,6) , (5,3), (5,6);
		
        UPDATE tbd_usuarios_roles SET rol_id = 5 WHERE usuario_id =1 and rol_id= 4; 
        DELETE FROM tbd_usuarios_roles WHERE usuario_id=5 and rol_id=6;
        
    ELSE 
      SELECT "La contraseña es incorrecta, no puedo mostrarte el 
      estatus de la Base de Datos" AS ErrorMessage;
    
    END IF;
		
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_servicios_medicos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`alexis.gomez`@`%` PROCEDURE `sp_poblar_servicios_medicos`(v_password VARCHAR(20))
BEGIN
 IF v_password = "1234" THEN
        -- Insertar nuevos registros en tbc_servicio_medico
        INSERT INTO tbc_servicios_medicos (nombre, descripcion, observaciones)
        VALUES ('Consulta Médica General', 'Revisión general del paciente por parte de un médico autorizado', 'Horario de Atención de 08:00 a 20:00');

        -- Se asignan los servicios al departamento que los brinda
        INSERT INTO tbd_departamentos_servicios VALUES
        (17, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT, NULL),
        (40, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT, NULL);
		
        
        
        INSERT INTO tbc_servicios_medicos (nombre, descripcion, observaciones)
        VALUES ('Consulta Médica Especializada', 'Revisión médica de especialidad', 'Previa cita, asignada despúes de una revisión general');
        
         -- Se asignan los servicios al departamento que los brinda
        INSERT INTO tbd_departamentos_servicios VALUES
        (10, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (11, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (12, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (13, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (14, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (15, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL);
        
		
        
        INSERT INTO tbc_servicios_medicos (nombre, descripcion, observaciones)
        VALUES ('Consulta Médica a Domicilio', 'Revision médica en el domicilio del paciente', 'Solo para casos de extrema urgencia');
        
		INSERT INTO tbc_servicios_medicos (nombre, descripcion, observaciones)
		VALUES ('Examen Físico Completo', 'Examen detallado de salud física del paciente', 'Asistir con ropa lijera y 6 a 8 de horas
        de ayuno previo');

		INSERT INTO tbc_servicios_medicos (nombre, descripcion, observaciones)
		VALUES ('Extracción de Sangre', 'Toma de muestra para análisis de sangre', 'Ayuno previo, muestras antes de las 10:00 a.m.');
        
        -- Se agrega un nuevo servicio medico
        INSERT INTO tbc_servicios_medicos (nombre, descripcion, observaciones)
        VALUES ('Parto Natural', 'Asistencia en el proceso de alumbramiento de un bebé', 'Sin observaciones');
        -- Asignamos el departamento que brinda ese servicio.
        INSERT INTO tbd_departamentos_servicios VALUES
        (13, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (14, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL);
               
        
        INSERT INTO tbc_servicios_medicos (nombre, descripcion, observaciones)
        VALUES ('Estudio de Desarrollo Infantil', 'Valoración de Crecimiento del Infante', 'Mediciones de Talla, Peso y Nutrición');
        INSERT INTO tbd_departamentos_servicios VALUES
        (13, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL);
        
        INSERT INTO tbc_servicios_medicos (nombre, descripcion, observaciones)
        VALUES ('Toma de Signos Vitales', 'Registro de Talla, Peso, Temperatura, Oxigenación en la Sangre , Frecuencia Cardiaca 
        (Sistólica y  Diastólica, Frecuencia Respiratoria', 'Necesarias para cualquier servicio médico.');
        INSERT INTO tbd_departamentos_servicios VALUES
        (13, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL), 
        (14, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (12, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (25, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (23, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL);
        
        DELETE FROM tbd_departamentos_servicios WHERE departamento_id=25;
        UPDATE tbd_departamentos_servicios SET Estatus=b'0' WHERE departamento_id=23;
        
        
        
        

        -- Actualizar un registro en tbc_servicio_medico
        UPDATE tbc_servicios_medicos 
        SET nombre="Estudio de Química Sanguínea" WHERE nombre='Extracción de Sangre';
        
        -- Eliminar un registro en tbc_servicio_medico
        DELETE FROM tbc_servicios_medicos WHERE nombre = 'Consulta Médica a Domicilio';
        
        
        
        

    ELSE 
        SELECT "La contraseña es incorrecta, no se puede realizar modificación en la tabla Servicio Medico" AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_solicitudes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`Carlos.Hernandez`@`%` PROCEDURE `sp_poblar_solicitudes`(v_password VARCHAR(10))
BEGIN
	IF v_password = "xYz$123" THEN
    
    INSERT INTO tbd_solicitudes  VALUES 
    (DEFAULT, 1, 1, 1, "Moderada", "Revisión médica anual para monitorear mi salud general.", "Registrada", DEFAULT, DEFAULT, NULL),
    (DEFAULT, 2, 2, 2, "Emergente", "Tratamiento médico para mejorar mi bienestar.", "Programada", DEFAULT, DEFAULT, NULL),
    (DEFAULT, 3, 3, 3, "Alta", "Consulta especializada para manejar una condición específica.", "Reprogramada", DEFAULT, DEFAULT, NULL),
    (DEFAULT, 4, 4, 4, "Normal", "Revisión mensual para monitorear i condicion cardiaca.", "En proceso", DEFAULT, DEFAULT, NULL),
    (DEFAULT, 5, 5, 5, "Urgente", "Revisión médica para ver mis niveles de salud.", "Realizada", DEFAULT, DEFAULT, NULL);
    
    UPDATE tbd_solicitudes SET prioridad = "Normal" WHERE ID = 1;
    UPDATE tbd_solicitudes SET estatus = "Cancelada" WHERE ID = 2;

	DELETE FROM tbd_solicitudes WHERE ID = 3;
    
    ELSE
		SELECT "La contraseña es incorrecta, no puede mostrar el
        estatus de la Base de Datos" AS ErrorMessage;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_tbd_horarios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`DiegoOliver`@`%` PROCEDURE `sp_poblar_tbd_horarios`()
BEGIN
    DECLARE contador INT DEFAULT 1;
    
    WHILE contador <= 5 DO
        INSERT INTO tbd_horarios (empleado_id, nombre, especialidad, dia_semana, hora_inicio, hora_fin, turno, nombre_departamento, nombre_sala) 
        VALUES (contador, 
                CONCAT('Doctor ', contador), 
                CONCAT('Especialidad ', contador), 
                'Lunes', 
                '08:00:00', 
                '16:00:00', 
                'Matutino', 
                CONCAT('Departamento ', contador % 3 + 1), 
                CONCAT('Sala ', contador % 2 + 1));
                
        SET contador = contador + 1;
    END WHILE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_usuarios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_usuarios`(v_password VARCHAR(20))
BEGIN  
	
    IF v_password = "xYz$123" THEN
		
		INSERT INTO tbb_usuarios 
        VALUES 
        (DEFAULT, 1, "marco.rahe", "marco.rahe@hotmail.com", "qwerty123", "(+52) 764 100 17 25", DEFAULT, DEFAULT, NULL),
        (DEFAULT, 2, "juan.perez", "j.perez@hotmail.com", "mipass", "(+52) 555 553 19 32", DEFAULT, DEFAULT, NULL),
        (DEFAULT, 3, "patito25", "patricia.reyes@hospitalito.mx", "gest#2235", "(+52) 222 235 44 01", DEFAULT, DEFAULT, NULL),
        (DEFAULT, 4, "liliana99", "lili.santamaria@privilegecare.com", "dasT8832", "(+52) 778 145 22 87", DEFAULT, DEFAULT, NULL),
        (DEFAULT, 5, "hugo.vera", "solnanov_hugo@gmail.com", "12345", "(+52) 758 98 16 32", DEFAULT, DEFAULT, NULL);
        
	
        UPDATE tbb_usuarios SET correo_electronico= "marco.rahe@gmail.com" WHERE nombre_usuario="marco.rahe";
        UPDATE tbb_usuarios SET estatus= "Bloqueado" WHERE correo_electronico="j.perez@hotmail.com";
        UPDATE tbb_usuarios SET estatus= "Suspendido" WHERE nombre_usuario="hugo.vera";
        
        DELETE FROM tbb_usuarios WHERE nombre_usuario="liliana99";
        
        
        
        
    ELSE 
      SELECT "La contraseña es incorrecta, no puedo mostrarte el 
      estatus de la Base de Datos" AS ErrorMessage;
    
    END IF;
		

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_valoraciones_medicas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_valoraciones_medicas`(v_password varchar(20))
BEGIN
IF v_password = "hola123" THEN
	




INSERT INTO tbb_valoraciones_medicas (
	id, paciente_id, fecha, antecedentes_personales, antecedentes_familiares, antecedentes_medicos, sintomas_signos, examen_fisico, pruebas_diagnosticas,
    diagnostico, plan_tratamiento, seguimiento) VALUES (1, 1,'2024-06-06','Sin antecedentes personales relevantes', 'Madre con diabetes tipo 2',
    'Hipertensión arterial diagnosticada hace 5 años', 'Dolor abdominal, náuseas', 'Abdomen distendido, signo de Murphy positivo', 'Ecografía abdominal',
    'Colecistitis aguda', 'Colecistectomía laparoscópica programada', 'Control postoperatorio en una semana');

INSERT INTO tbb_valoraciones_medicas (
	id, paciente_id, fecha, antecedentes_personales, antecedentes_familiares, antecedentes_medicos, sintomas_signos, examen_fisico, pruebas_diagnosticas,
    diagnostico, plan_tratamiento, seguimiento) VALUES (2, 2, '2024-06-07', 'Fumador ocasional', 'Padre con hipertensión', 'Asma diagnosticada en la infancia',
    'Tos persistente, dificultad para respirar', 'Sibilancias en ambos campos pulmonares', 'Espirometría', 'Asma bronquial', 'Tratamiento con broncodilatadores',
    'Revisión en dos semanas');

INSERT INTO tbb_valoraciones_medicas (
    id, paciente_id, fecha, antecedentes_personales, antecedentes_familiares, antecedentes_medicos, sintomas_signos, examen_fisico, pruebas_diagnosticas,
    diagnostico, plan_tratamiento, seguimiento) VALUES(3, 3, '2024-06-07', 'Deportista regular, sin antecedentes de tabaquismo', 'Madre con osteoporosis',
    'Ninguno', 'Dolor en la rodilla derecha al correr', 'Inflamación en la rodilla derecha', 'Radiografía de rodilla', 'Tendinitis rotuliana', 'Fisioterapia y antiinflamatorios',
    'Revisión en un mes');

INSERT INTO tbb_valoraciones_medicas (
id, paciente_id, fecha, antecedentes_personales, antecedentes_familiares, antecedentes_medicos, sintomas_signos, examen_fisico, pruebas_diagnosticas,
    diagnostico, plan_tratamiento, seguimiento) VALUES (4, 4, '2024-06-07', 'Alergia a los mariscos', 'Hermano con asma', 'Alergias estacionales',
    'Erupción cutánea y picazón después de comer mariscos', 'Erupciones eritematosas en brazos y piernas', 'Pruebas de alergia cutánea', 'Alergia alimentaria a mariscos',
    'Antihistamínicos y evitar mariscos', 'Revisión en tres meses');

UPDATE tbb_valoraciones_medicas
SET plan_tratamiento = 'Nuevo plan de tratamiento'
WHERE id = 1;


DELETE FROM tbb_valoraciones_medicas
WHERE paciente_id = 1;



ELSE
	select "La contraseña es incorrecta, no puedo mostrarte el estatus de la base de datos"  AS ErrorMessage;
END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_roles_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_roles_usuario`(v_correo_electronico VARCHAR(60))
BEGIN
   -- Verificamos si el usuario existe
   IF (SELECT COUNT(*) FROM tbb_usuarios WHERE correo_electronico = v_correo_electronico) >0 THEN
	 -- Verificamos si el usuario se encuentra Bloqueado
	 IF (SELECT estatus FROM tbb_usuarios WHERE correo_electronico = v_correo_electronico) = "Bloqueado"  THEN 
       SELECT CONCAT_WS(" ", "El usuario:", v_correo_electronico,"actualmente se encuentrá bloqueado del sistema.") as Mensaje;
	-- Verificamos si el usuario se encuentra Suspendido 
     ELSEIF (SELECT estatus FROM tbb_usuarios WHERE correo_electronico = v_correo_electronico) = "Suspendido"  THEN 
       SELECT CONCAT_WS(" ", "El usuario:", v_correo_electronico," ha sido suspendido del uso del sistema.") as Mensaje;
	 ELSE
		SELECT r.Nombre FROM 
        tbc_roles r 
        JOIN tbd_usuarios_roles ur ON ur.rol_id = r.id
        JOIN tbb_usuarios u ON ur.usuario_id = u.id
        WHERE u.correo_electronico=v_correo_electronico AND ur.estatus = TRUE;
	END IF;
	ELSE 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario especificado no existe';
   END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-08-22 12:12:43
