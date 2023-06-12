﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Distr].[TYPE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Distr].[TYPE_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Distr].[TYPE_SELECT]
	@FILTER			NVARCHAR(512) = NULL,
	@SHOW_INACTIVE	BIT = 0,
	@RC				SMALLINT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		SELECT ID, SHORT, STATUS
		FROM Distr.Type
		WHERE (STATUS = 1 OR STATUS = 3 AND @SHOW_INACTIVE = 1)
			AND
				(
					@FILTER IS NULL
					OR SHORT LIKE @FILTER
				)
		ORDER BY SHORT


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
GRANT EXECUTE ON [Distr].[TYPE_SELECT] TO rl_distr_type_r;
GO
