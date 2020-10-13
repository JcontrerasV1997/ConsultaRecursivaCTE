
 ---Tabla Temporal en memoria para optimizacion, esta es una tabla para pruebas.
DECLARE @Empresa AS TABLE(
 
 idDepartamento INT primary key not null,--id comun, se puede representar como id de empresa
 idSubDepartamento INT,--este seria lo que se denomina como el ID padre o parent
 departamento VARCHAR(50),--ES UN SUBDEPARTAMENTO en si
 nombreGerente VARCHAR(50),
 numeroTelefono varchar(100),
 fechaNacimiento date,
 fechaInicio date
 )

 ---Tabla Comun para ejecucion, aqui creo la tabla. Teniendo en cuenta cualquier requierimiento nuevo
 -- se puede agregar cambiar gerente id por idDepartamento y idDepartamento por idSubdepartamento
 --hay que tener en cuenta que la relacion recursiva es comparada con ella misma
 --en todo caso dependiendo del requerimiento este se puede enfocar.
 -- la tabla puede llamarse empresa o base de datos

create table Empresa (
 id INT ,--id comun, se puede representar como id de empresa o depende
 idDepartamento INT,--este seria lo que se denomina como el ID padre o parent
 departamento VARCHAR(50),--ES UN SUBDEPARTAMENTO en si
 nombreGerente VARCHAR(50),
 numeroTelefono varchar(100),
 fechaNacimiento date,
 fechaInicio date
 )

--el id del padre es el departamento
INSERT INTO Empresa(id, idDepartamento,departamento,nombreGerente,numeroTelefono, fechaNacimiento,fechaInicio) 
VALUES(1 , NULL , 'INGENIERIA','juan manuel','3168102927','19900415','20200910')  --DEPARTAMENTOS
    , (2 , NULL , 'CONTABILIDAD','Jorge luis','31845612','19600615','20190602')
    , (3 , NULL , 'PRUEBAS','junior','3645187941','19900302','20180602')
    , (4 , 2 , 'Cuentas Cobro','karen del valle','320451646','19900304','20170403')--SUBDEPARTAMENTOS y se pueden agregar dentro de ellos para su representacion
    , (5 , 1 , 'SOFTWARE','owen','34612451','19990306','20200304')
    , (6 , 2 , 'AUDITORIA CONTABLE','lastra','314647841','19700409','20170406')
    , (7 , 1 , 'ARQUITECTURA DE SOFTWARE','miguel','314654272','19960604','20150603')
    , (8 , 1 , 'OPTIMIZACION CODIGO','jose alfaro','36451874','19980302','20200506')
    , (9 , 3 , 'UNITARIAS','steven','33164577','19980419','20200306')
	, (10 ,1 , 'CIVIL','aroldy','3212346212','19800816','20200419')
	


	create view Vista --creacion de vista en sql
	as
WITH consultaRecursiva	--iniciamos consulta recursiva
		AS
(
    SELECT 
         id, 
        idDepartamento, 
		departamento,
		nombreGerente,
		numeroTelefono,
		fechaNacimiento,
		fechaInicio,
        0 AS NivelJerarquia,--acoplo las columnas dentro de este alias para optimizar su seleccion
        CAST(RIGHT(REPLICATE('_',5) + 
		CONVERT(VARCHAR(20),id),20) AS VARCHAR(MAX))
		 AS OrdenarPorCampo--hago una conversion para agregar cadena indicativa para referenciar el id de la empresa
	FROM Empresa
		 WHERE idDepartamento IS NULL--los campos nulos representan los departamentos Padres estos indican que nadie esta por encima de ellos por eso se hace este where
    UNION ALL
	--unimos con una sentencia join para compararse a si mismo el CTE, 
	--por eso compararemos con los diferentes area para que no exista ambiguedad entre las tablas.
    SELECT 
        _empresa.id, 
        _empresa.idDepartamento, 
		_empresa.departamento,
		_empresa.nombreGerente, 
		_empresa.numeroTelefono,
		_empresa.fechaNacimiento,
		_empresa.fechaInicio,
        (CTE.NivelJerarquia + 1) AS NivelJerarquia,--TENEMOS EL INDICATIVO PARA EL NIVEL DE JERARQUIA por el area, le sumo uno para indicar que el 0 no depende
        CTE.OrdenarPorCampo + CAST(RIGHT(REPLICATE('_',5)--ALIAS PARA ORDENAMIENTO Y CONCATENACION DE GUIONES e INDICATIVOS 
							+ CONVERT(VARCHAR(20),_empresa.id),20) 
								AS VARCHAR(MAX)) AS OrdenarPorCampo
    FROM Empresa _empresa
    INNER JOIN consultaRecursiva CTE ON CTE.id= _empresa.idDepartamento--HACEMOS EL JOIN CON LAS ANCLAS
    WHERE _empresa.idDepartamento IS NOT NULL--INDICAMOS EL FILTRO PARA CON LOS PADRES
)
-- AL FINAL TENDREMOS LA SELECCION DE LOS CAMPOS Y ALIAS
SELECT 
     id
    , departamento AS DEPARTAMENTO
    , idDepartamento
    , NivelJerarquia
    , (REPLICATE( '----' , NivelJerarquia ) + departamento) AS ArbolJerargico--NIVEL DE JERARQUIA PRINCIPAL INDICA QUE ES PADRE
	, nombreGerente
	,numeroTelefono
	,fechaNacimiento
	,fechaInicio
	,OrdenarPorCampo --debo selecionar este alias para poder compararlo directamente en el framework porque no puedo agregar order by a una vista
FROM consultaRecursiva
ORDER BY OrdenarPorCampo,departamento; --UN BREVE ORDENAMIENTO PARA AGREGAR