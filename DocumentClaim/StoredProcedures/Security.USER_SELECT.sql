USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[USER_SELECT]
	@FILTER	NVARCHAR(512) = NULL,
	@RC		INT = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		SELECT
			b.ID, a.NAME, b.CAPTION, c.NAME AS DEP_NAME, HEAD,
			REVERSE(STUFF(REVERSE(
				(
					SELECT CAPTION + ', '
					FROM
						Security.RoleGroup z
						INNER JOIN sys.database_principals y ON z.NAME = y.NAME
						INNER JOIN sys.database_role_members x ON x.role_principal_id = y.principal_id
						INNER JOIN sys.database_principals w ON w.principal_id = x.member_principal_id
					WHERE y.TYPE = 'R' AND w.NAME = b.NAME
					ORDER BY CAPTION FOR XML PATH('')
				)), 1, 2, '')
			) AS USER_GROUP,
			REVERSE(STUFF(REVERSE(
				(
					SELECT t.CAPTION + CHAR(10)
					FROM
						sys.database_principals z
						INNER JOIN sys.database_role_members y ON z.principal_id = y.role_principal_id
						INNER JOIN sys.database_principals x ON x.principal_id = y.member_principal_id
						INNER JOIN Security.RoleCaptionView t ON t.NAME = z.name
					WHERE x.type <> 'R' AND z.name LIKE 'rl[_]%' AND x.NAME = b.NAME
					ORDER BY z.name, t.name FOR XML PATH('')
				)), 1, 1, '')
			) AS USER_INDIVID,
			CASE TYPE
				WHEN 'S' THEN 'SQL'
				WHEN 'U' THEN 'WIN'
			END AS USER_TYPE
		FROM
			sys.database_principals a
			LEFT OUTER JOIN Security.Users b ON a.name = b.NAME
												AND b.STATUS = 1
			LEFT OUTER JOIN Security.Department c ON c.ID = b.ID_DEPARTMENT
		WHERE TYPE IN ('S', 'U')
			AND a.NAME NOT IN ('dbo', 'guest', 'INFORMATION_SCHEMA', 'sys')
			AND
				(
					@FILTER IS NULL
					OR b.CAPTION LIKE @FILTER
					OR b.NAME LIKE @FILTER
				)
		ORDER BY b.CAPTION, a.NAME

		SELECT @RC = @@ROWCOUNT

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
GRANT EXECUTE ON [Security].[USER_SELECT] TO rl_user_r;
GO
