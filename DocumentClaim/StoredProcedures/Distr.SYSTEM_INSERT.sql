﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[SYSTEM_INSERT]
	@ID		UNIQUEIDENTIFIER OUTPUT,
	@SHORT	NVARCHAR(128),
	@REG	NVARCHAR(64),
	@HOST	UNIQUEIDENTIFIER,
	@ORD	INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO Distr.System(SHORT, REG, ID_HOST, ORD)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@SHORT, @REG, @HOST, @ORD)

		SELECT @ID = ID
		FROM @TBL

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
GRANT EXECUTE ON [Distr].[SYSTEM_INSERT] TO rl_system_u;
GO
