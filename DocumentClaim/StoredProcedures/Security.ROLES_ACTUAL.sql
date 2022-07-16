USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[ROLES_ACTUAL]
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		;WITH user_roles AS
			(
				SELECT r.name AS RL_NAME, r.principal_id AS RL_ID
				FROM
					sys.database_principals u
					INNER JOIN sys.database_role_members ur ON u.principal_id = ur.member_principal_id
					INNER JOIN sys.database_principals r ON r.principal_id = ur.role_principal_id
				WHERE u.TYPE IN ('S', 'U') AND u.NAME = ORIGINAL_LOGIN()

				UNION ALL

				SELECT r.name AS RL_NAME, r.principal_id AS RL_ID
				FROM
					user_roles u
					INNER JOIN sys.database_role_members ur ON u.RL_ID = ur.member_principal_id
					INNER JOIN sys.database_principals r ON r.principal_id = ur.role_principal_id
			)
		SELECT RL_NAME, CAPTION
		FROM
			user_roles a
			LEFT OUTER JOIN Security.RoleCaptionView b ON a.RL_NAME = b.NAME
		ORDER BY CAPTION

		/*
		WAITFOR DELAY '00:00:05'

		SELECT RL_NAME, ISNULL(CAPTION, RL_NAME) AS CAPTION
		FROM
			(
				SELECT a.name AS RL_NAME
				FROM
					sys.database_principals a
					INNER JOIN sys.database_role_members b ON b.role_principal_id = a.principal_id
					INNER JOIN sys.database_principals c ON c.principal_id = b.member_principal_id
				WHERE c.name = ORIGINAL_LOGIN()

				UNION ALL

				SELECT e.name
				FROM
					sys.database_principals a
					INNER JOIN sys.database_role_members b ON b.member_principal_id = a.principal_id
					INNER JOIN sys.database_principals c ON b.role_principal_id = c.principal_id
					INNER JOIN sys.database_role_members d ON d.member_principal_id = c.principal_id
					INNER JOIN sys.database_principals e ON d.role_principal_id = e.principal_id
				WHERE a.name = ORIGINAL_LOGIN()
			) AS a
			LEFT OUTER JOIN Security.RoleCaptionView b ON a.RL_NAME = b.NAME
		ORDER BY CAPTION
		*/

		EXEC Maintenance.FINISH_PROC @@PROCID
	END TRY
	BEGIN CATCH
		DECLARE	@SEV	INT
		DECLARE	@STATE	INT
		DECLARE	@NUM	INT
		DECLARE	@PROC	NVARCHAR(128)
		DECLARE	@MSG	NVARCHAR(2048)

		SELECT
			@SEV	=	ERROR_SEVERITY(),
			@STATE	=	ERROR_STATE(),
			@NUM	=	ERROR_NUMBER(),
			@PROC	=	ERROR_PROCEDURE(),
			@MSG	=	ERROR_MESSAGE()

		EXEC Maintenance.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[ROLES_ACTUAL] TO public;
GO
