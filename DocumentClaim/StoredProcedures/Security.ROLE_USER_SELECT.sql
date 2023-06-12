USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[ROLE_USER_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[ROLE_USER_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[ROLE_USER_SELECT]
	@ROLE	NVARCHAR(128),
	@USER	NVARCHAR(128)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		SELECT
			1 AS TP, NEWID() AS ID, CONVERT(UNIQUEIDENTIFIER, NULL) AS ID_MASTER,
			a.NAME, b.CAPTION,
			CONVERT(BIT, CASE
				WHEN c.NAME IS NULL THEN 0
				ELSE 1
			END) AS CHECKED
		FROM
			sys.database_principals a
			LEFT OUTER JOIN Security.Users b ON a.name = b.NAME
												AND b.STATUS = 1
			LEFT OUTER JOIN
				(
					SELECT x.NAME
					FROM
						sys.database_principals z
						INNER JOIN sys.database_role_members y ON z.principal_id = y.role_principal_id
						INNER JOIN sys.database_principals x ON x.principal_id = y.member_principal_id
					WHERE z.NAME = @ROLE
				) AS c ON c.NAME = a.NAME
		WHERE TYPE IN ('S', 'U')
			AND a.NAME NOT IN ('dbo', 'guest', 'INFORMATION_SCHEMA', 'sys')
			AND (
					a.NAME LIKE @USER OR @USER IS NULL
					OR b.CAPTION LIKE @USER
				)

		UNION ALL

		SELECT
			0 AS TP, NEWID() AS ID, CONVERT(UNIQUEIDENTIFIER, NULL) AS ID_MASTER,
			a.NAME, b.CAPTION,
			CONVERT(BIT, CASE
				WHEN c.NAME IS NULL THEN 0
				ELSE 1
			END) AS CHECKED
		FROM
			sys.database_principals a
			INNER JOIN Security.RoleGroup b ON a.name = b.NAME
												AND b.STATUS = 1
			LEFT OUTER JOIN
				(
					SELECT x.NAME
					FROM
						sys.database_principals z
						INNER JOIN sys.database_role_members y ON z.principal_id = y.role_principal_id
						INNER JOIN sys.database_principals x ON x.principal_id = y.member_principal_id
					WHERE z.NAME = @ROLE
				) AS c ON c.NAME = a.NAME
		WHERE TYPE IN ('R')
			AND a.NAME NOT IN ('dbo', 'guest', 'INFORMATION_SCHEMA', 'sys')
			AND (
					a.NAME LIKE @USER OR @USER IS NULL
					OR b.CAPTION LIKE @USER
				)

		ORDER BY TP, CAPTION, NAME

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
GRANT EXECUTE ON [Security].[ROLE_USER_SELECT] TO rl_user_permission_r;
GO
