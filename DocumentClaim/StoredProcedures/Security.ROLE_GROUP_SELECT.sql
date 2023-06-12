﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[ROLE_GROUP_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[ROLE_GROUP_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[ROLE_GROUP_SELECT]
	@FILTER			NVARCHAR(256) = NULL,
	@SHOW_INACTIVE	BIT	= NULL,
	@RC				INT = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		SELECT ID, NAME, CAPTION, NOTE, STATUS
		FROM Security.RoleGroup
		WHERE (STATUS = 1 OR STATUS = 3 AND @SHOW_INACTIVE = 1)
			AND
				(
					@FILTER IS NULL
					OR NAME LIKE @FILTER
					OR CAPTION LIKE @FILTER
					OR NOTE LIKE @FILTER
				)
		ORDER BY CAPTION

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
GRANT EXECUTE ON [Security].[ROLE_GROUP_SELECT] TO rl_user_r;
GO
