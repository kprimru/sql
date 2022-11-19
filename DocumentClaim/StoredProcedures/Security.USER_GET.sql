USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[USER_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		SELECT
			CAPTION, ID_DEPARTMENT, HEAD,
			CASE l.type WHEN 'U' THEN a.NAME ELSE NULL END AS NAME,
			CASE l.type WHEN 'S' THEN a.NAME ELSE NULL END AS SQL_NAME,
			Cast(CASE l.type WHEN 'S' THEN 0 WHEN 'U' THEN 1 ELSE NULL END AS Bit) AS WinUser,
			ISNULL((
				SELECT '{' + CONVERT(NVARCHAR(128), c.ID) + '}' AS "item/@id"
				FROM
					Security.RoleGroup c
					INNER JOIN sys.database_principals d ON c.NAME = d.NAME
					INNER JOIN sys.database_role_members e ON e.role_principal_id = d.principal_id
					INNER JOIN sys.database_principals f ON e.member_principal_id = f.principal_id
				WHERE f.NAME = a.NAME
				ORDER BY c.NAME FOR XML PATH(''), ROOT ('root')
			), '') AS GROUPS
		FROM Security.Users a
		LEFT JOIN sys.server_principals AS l ON l.name = a.NAME
		WHERE ID = @ID

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
GRANT EXECUTE ON [Security].[USER_GET] TO rl_user_r;
GO
