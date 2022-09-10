﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[NET_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@SHORT	NVARCHAR(64),
	@COUNT	SMALLINT,
	@TECH	SMALLINT,
	@COEF	DECIMAL(8, 4)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		UPDATE Distr.Net
		SET SHORT		=	@SHORT,
			NET_COUNT	=	@COUNT,
			TECH		=	@TECH,
			COEF		=	@COEF,
			LAST		=	GETDATE()
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
GRANT EXECUTE ON [Distr].[NET_UPDATE] TO rl_net_u;
GO