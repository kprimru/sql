﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Claim].[CONDITION_STATUS]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Claim].[CONDITION_STATUS]  AS SELECT 1')
GO

ALTER PROCEDURE [Claim].[CONDITION_STATUS]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		UPDATE Claim.Condition
		SET STATUS	=	CASE STATUS WHEN 1 THEN 3 WHEN 3 THEN 1 ELSE 1 END,
			LAST	=	GETDATE()
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
GRANT EXECUTE ON [Claim].[CONDITION_STATUS] TO rl_condition_h;
GO
