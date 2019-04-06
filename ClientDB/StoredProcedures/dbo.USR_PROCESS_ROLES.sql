USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USR_PROCESS_ROLES]
	@LOGIN		VARCHAR(100) = NULL,
	@NT			BIT = NULL,
	@REPLACE	BIT	= NULL OUTPUT,
	@ACCESS		BIT = NULL OUTPUT 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @roles TABLE
		(
			RL_NAME VARCHAR(100)
		)	

	IF @LOGIN IS NOT NULL
		INSERT INTO @roles(RL_NAME)
			SELECT c.[name]
			FROM	 
				sys.database_principals a INNER JOIN
				sys.database_role_members b ON a.principal_id = b.member_principal_id INNER JOIN
				sys.database_principals c ON c.principal_id = b.role_principal_id
			WHERE 
				a.[name] = @login
				AND a.[type] = 'S'
	ELSE IF @NT = 1
		INSERT INTO @roles(RL_NAME)
			SELECT c.[name]
			FROM	 
				sys.database_principals a INNER JOIN
				sys.database_role_members b ON a.principal_id = b.member_principal_id INNER JOIN
				sys.database_principals c ON c.principal_id = b.role_principal_id
			WHERE
				a.[name] = ORIGINAL_LOGIN()
				AND a.[type] = 'S'
		

	IF EXISTS(SELECT * FROM @roles WHERE RL_NAME IN ('db_owner', 'DBChief', 'DBManager', 'DBSuperManager', 'DBQuality', 'DBRivman'))
		SET @REPLACE = 1
	ELSE
		SET @REPLACE = 0

	IF EXISTS
		(
			SELECT *
			FROM			 
				@roles 
			WHERE RL_NAME IN ('db_owner', 'DBChief', 'DBManager', 'DBSuperManager', 'DBQuality', 'DBRivman')			
		)
		SET @ACCESS = 1
	ELSE
		SET @ACCESS = 0
END