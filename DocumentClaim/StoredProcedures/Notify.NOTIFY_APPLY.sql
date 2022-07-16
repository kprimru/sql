﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Notify].[NOTIFY_APPLY]
	@EVENT	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		UPDATE a
		SET RECEIVE_DATE = GETDATE()
		FROM
			Notify.Message a
			INNER JOIN Security.Users b ON a.ID_RECEIVER = b.ID
		WHERE b.NAME = ORIGINAL_LOGIN() AND RECEIVE_DATE IS NULL AND ID_EVENT = @EVENT

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
GRANT EXECUTE ON [Notify].[NOTIFY_APPLY] TO public;
GO
