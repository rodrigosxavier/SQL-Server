-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Criando um Banco de Dados /**/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DROP DATABASE IF EXISTS RodrigoBD
CREATE DATABASE RodrigoBD

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Criando Login, Usuário e vinculando a um Banco de Dados
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

USE [master]
GO
CREATE LOGIN [Rodrigo] WITH PASSWORD=N'rodrigo@123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO
USE [RodrigoBD]
GO
CREATE USER [Rodrigo] FOR LOGIN [Rodrigo]
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Verificar Logins do servidor
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select 
	name,
	create_date,
	modify_date,
	LOGINPROPERTY(name,'DaysUntilExpiration') DiasParaExpirar,
	LOGINPROPERTY(name,'PasswordLastSetTime') DataHoradaUltimaSenha,
	LOGINPROPERTY(name,'IsExpired') PodeExpirar,
	LOGINPROPERTY(name,'IsMustChange') PodeMudar, *
from sys.sql_logins

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Verificar todas as conexões de um usuário (sys.sysprocesses view do sql server)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select * from sys.sysprocesses
where loginame= 'Rodrigo'

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Conceder permissão de SELECT a um login de Banco de Dados (Login que concede acesso deve ser "sysadmin")
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

GRANT SELECT/*DML- UPDATE, DELETE, ALTER, EXECUTE*/ ON tbRodrigo/*OBJETO - TABELA, VIEW, Procedure,*/ TO Rodrigo

-- Concede acesso ao login a todos os objetos
GRANT EXECUTE TO Rodrigo /*EXECUTE PODE DELETAR INSERIR ETC DENTRO DE UMA PROCEDURE*/

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Negar permissão de SELECT a um login de Banco de Dados (Login que concede acesso deve ser "sysadmin")
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DENY SELECT/*DML- UPDATE, DELETE, ALTER, EXECUTE*/ ON tbRodrigo/*OBJETO - TABELA, VIEW, Procedure,*/ TO Rodrigo

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Revoga/Retira permissão de SELECT a um login de Banco de Dados (Login que concede acesso deve ser "sysadmin")
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

REVOKE SELECT/*DML- UPDATE, DELETE, ALTER, EXECUTE*/ ON tbRodrigo/*OBJETO - TABELA, VIEW, Procedure,*/ TO Rodrigo

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Query para retornar as permissões que são dadas a nivel de objetos
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 
	--pr.principal_id, 
	pr.name, 
	pr.type_desc,   
    pr.authentication_type_desc, 
	pe.state_desc,   
    pe.permission_name, 
	s.name + '.' + o.name AS ObjectName, 
	SP.type_desc,
	SP.name, pe.*, sp.*
FROM sys.database_principals AS pr  
JOIN sys.database_permissions AS pe  
    ON pe.grantee_principal_id = pr.principal_id  
JOIN sys.objects AS o  
    ON pe.major_id = o.object_id  
JOIN sys.schemas AS s  
    ON o.schema_id = s.schema_id
/*JOIN sys.all_objects AS SP
	ON pe.major_id = SP.object_id
	AND pe.minor_id = sp.parent_object_id   AJUSTAR ESSE RELACIONAMENTO*/
WHERE pr.name = 'innova'

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Query para retornar as Database Roles de um Banco de Bados
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 
	P.NAME, 
	P.TYPE_DESC,
	PP.NAME,
	PP.TYPE_DESC,
	PP.IS_FIXED_ROLE
FROM sys.database_role_members AS ROLES
JOIN sys.database_principals AS P 
	ON ROLES.member_principal_id = P.principal_id
JOIN sys.database_principals AS PP 
	ON ROLES.member_principal_id = PP.principal_id
ORDER BY 1

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Liberando acesso de leitura de todas as tabelas
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

USE RodrigoDB
GO

ALTER ROLE [db_datareade] ADD MEMBER [Rodrigo]
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Negar select numa tabela 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DENY SELECT ON PFUNC TO [Rodrigo]

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Excluindo login
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DROP LOGIN [Rodrigo]
GO

-- Verifica conexões aberto
SELECT 
	loginame,
	spid
FROM sysprocesses
WHERE loginame = 'Rodrigo' 

-- Fecha a sessão
KILL 162

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Excluindo usuário orfão (lixo)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DROP USER [Rodrigo]
GO