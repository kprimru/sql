﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[ROLE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[ROLE_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[ROLE_SELECT]
	@USER NVARCHAR(128) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		IF @USER IS NULL
			SELECT ID, ID_MASTER, NAME, CAPTION, NOTE
			FROM Security.Roles
			ORDER BY CAPTION, NAME
		ELSE
		BEGIN
			SELECT ID, ID_MASTER, NAME, CAPTION, NOTE
			FROM Security.Roles a
			WHERE NAME IS NULL
				OR EXISTS
				(
					SELECT *
					FROM
						sys.database_principals b
						INNER JOIN sys.database_role_members c ON b.principal_id = c.member_principal_id
						INNER JOIN sys.database_principals d ON c.role_principal_id = d.principal_id
					WHERE b.NAME = @USER
						AND b.TYPE IN ('S', 'U')
						AND d.TYPE = 'R'
						AND d.NAME = a.NAME
				)
			ORDER BY CAPTION, NAME
		END

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
GRANT EXECUTE ON [Security].[ROLE_SELECT] TO rl_user_permission_r;
GO
