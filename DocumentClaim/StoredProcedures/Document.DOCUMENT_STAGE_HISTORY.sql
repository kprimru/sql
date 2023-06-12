﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Document].[DOCUMENT_STAGE_HISTORY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Document].[DOCUMENT_STAGE_HISTORY]  AS SELECT 1')
GO
ALTER PROCEDURE [Document].[DOCUMENT_STAGE_HISTORY]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		SELECT
			NAME, DATE, NOTE, CAPTION,
			Common.TimeSecToStr(ABS(DATEDIFF(SECOND, DATE, DT_PREV))) AS DELTA
		FROM
			(
				SELECT
					b.NAME, DATE, NOTE, c.CAPTION,
					(
						SELECT TOP 1 z.DATE
						FROM Document.DocumentStage z
						WHERE z.ID_DOCUMENT = @ID AND z.DATE < a.DATE
						ORDER BY z.DATE DESC
					) AS DT_PREV
				FROM
					Document.DocumentStage a
					INNER JOIN Document.Stage b ON a.ID_STAGE = b.ID
					INNER JOIN Security.Users c ON c.ID = a.ID_AUTHOR
				WHERE a.ID_DOCUMENT = @ID
			) AS o_O
		ORDER BY DATE DESC

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
GRANT EXECUTE ON [Document].[DOCUMENT_STAGE_HISTORY] TO rl_document_r;
GO
