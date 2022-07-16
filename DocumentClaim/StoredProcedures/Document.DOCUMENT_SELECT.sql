﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Document].[DOCUMENT_SELECT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@DOC_NUM	NVARCHAR(256),
	@STAGE		NVARCHAR(MAX),
	@CLIENT		NVARCHAR(512) = NULL,
	@TYPE		UNIQUEIDENTIFIER = NULL,
	@RC			INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		SELECT
			a.ID, a.DATE, CL_NAME, b.NAME, a.NUM, a.NOTE,
			c.DATE AS STATUS_DATE, c.CAPTION AS STATUS_USER, c.NOTE AS STATUS_NOTE, c.NAME AS STATUS_NAME
		FROM
			Document.Document a
			INNER JOIN Document.Type b ON b.ID = a.ID_TYPE
			CROSS APPLY
				(
					SELECT TOP 1 DATE, y.CAPTION, NOTE, x.NAME
					FROM
						Document.DocumentStage z
						INNER JOIN Security.Users y ON z.ID_AUTHOR = y.ID
						INNER JOIN Document.Stage x ON x.ID = z.ID_STAGE
					WHERE z.ID_DOCUMENT = a.ID
					ORDER BY z.DATE DESC
				) AS c
		WHERE a.STATUS = 1
			AND (DATE_S >= @BEGIN OR @BEGIN IS NULL)
			AND (DATE_S <= @END OR @END IS NULL)
			AND (NUM LIKE @DOC_NUM OR @DOC_NUM IS NULL)
			AND (CL_NAME LIKE @CLIENT OR @CLIENT IS NULL)
			AND (ID_TYPE = @TYPE OR @TYPE IS NULL)
		ORDER BY DATE DESC, CL_NAME

		SELECT @RC = @@ROWCOUNT

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
GRANT EXECUTE ON [Document].[DOCUMENT_SELECT] TO rl_document_r;
GO
