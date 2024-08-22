SELECT * FROM hospital_general_9a_idgs_210540.tbd_recetas_medicas;

SELECT * FROM hospital_general_9a_idgs_210540.tbd_recetas_detalles;
SELECT * FROM hospital_general_9a_idgs_210540.tbd_receta_medicamentos;
SELECT * FROM hospital_general_9a_idgs_210540.tbb_personal_medico;
SELECT * FROM hospital_general_9a_idgs_210540.tbb_pacientes;

call hospital_general_9a_idgs_210540.sp_poblar_recetas('141002', 16, 20, 5);
call hospital_general_9a_idgs_210540.sp_poblar_recetas_medicamentos('141002', 1, 3);
call hospital_general_9a_idgs_210540.sp_poblar_recetas_detalles('141002', 1, 2);


CREATE DEFINER=`marvin.tolentino`@`localhost` PROCEDURE `sp_poblar_recetas`(
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
                CURDATE(),  -- Fecha de actualización
                generar_diagnosticos(),  -- Generar un diagnóstico dinámico
                v_id_paciente,  -- ID del paciente
                v_id_medico  -- ID del médico
            );

            -- Incrementar el contador
            SET v_counter = v_counter + 1;
        END WHILE;

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password incorrecto';
    END IF;
END

-- --------------------------

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
END
--


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

END




