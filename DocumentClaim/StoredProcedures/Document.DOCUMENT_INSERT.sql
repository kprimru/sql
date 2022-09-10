﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Document].[DOCUMENT_INSERT]
	@ID			UNIQUEIDENTIFIER OUTPUT,
	@ID_CLIENT	NVARCHAR(128),
	@CL_TYPE	NVARCHAR(16),
	@CL_NAME	NVARCHAR(256),
	@ID_TYPE	UNIQUEIDENTIFIER,
	@DOC_NUM	NVARCHAR(256),
	@NOTE		NVARCHAR(MAX),
	@PERSONAL	NVARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		BEGIN TRAN

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		INSERT INTO Document.Document(DATE, ID_CLIENT, CL_TYPE, CL_NAME, ID_TYPE, NUM, NOTE, PERSONAL)
			OUTPUT inserted.ID INTO @TBL
			SELECT GETDATE(), @ID_CLIENT, @CL_TYPE, @CL_NAME, @ID_TYPE, @DOC_NUM, @NOTE, @PERSONAL

		SELECT @ID = ID
		FROM @TBL


		INSERT INTO Document.DocumentStage(ID_DOCUMENT, ID_STAGE, NOTE, ID_AUTHOR)
			SELECT TOP 1 @ID, a.ID, N'', b.ID
			FROM Document.Stage a, Security.Users b
			WHERE a.ID_TYPE = @ID_TYPE AND b.NAME = ORIGINAL_LOGIN()
			ORDER BY INDX

		/*
		INSERT INTO Notify.Message(ID_SENDER, ID_RECEIVER, TXT, MODULE, ID_EVENT)
			SELECT
				z.ID, d.ID,
				N'Новый документ "' + @CL_NAME + N'" от ' + z.CAPTION,
				N'DOCUMENT', @ID
			FROM
				Security.UserRoleView a
				INNER JOIN Security.Users d ON d.NAME = a.US_NAME
				CROSS JOIN
					(
						SELECT ID, CAPTION
						FROM Security.Users
						WHERE NAME = ORIGINAL_LOGIN()
					) AS z
			WHERE  a.RL_NAME = 'rl_claim_notify_create'
			*/

		COMMIT

		EXEC Maintenance.FINISH_PROC @@PROCID
	END TRY
	BEGIN CATCH
		ROLLBACK

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