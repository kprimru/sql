﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Claim].[CLIENT_TYPE_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Claim].[CLIENT_TYPE_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Claim].[CLIENT_TYPE_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	NVARCHAR(128),
	@PSEDO	NVARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		UPDATE Claim.ClientType
		SET NAME	=	@NAME,
			PSEDO	=	@PSEDO,
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
GRANT EXECUTE ON [Claim].[CLIENT_TYPE_UPDATE] TO rl_client_type_u;
GO
