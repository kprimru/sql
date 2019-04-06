USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Security].[USER_CHRONO]
	@US_NAME		VARCHAR(50),	
	@US_LOGIN		VARCHAR(50),
	@US_NOTE		VARCHAR(250),
	@US_DATE		SMALLDATETIME,
	@US_ID_MASTER	UNIQUEIDENTIFIER,
	@US_END			SMALLDATETIME,
	@US_ID			UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
	DECLARE @MASTERID UNIQUEIDENTIFIER


	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE	Security.UserDetail
		SET		US_END	=	@US_END,
				US_REF	=	2
		WHERE	US_ID	=	@US_ID	

		UPDATE	Security.Users
		SET		USMS_LAST	=	GETDATE()
		WHERE	USMS_ID		=	@US_ID_MASTER

		INSERT INTO 
				Security.UserDetail(
					US_ID_MASTER,
					US_NAME,
					US_LOGIN,
					US_NOTE,
					US_DATE
				)
		OUTPUT INSERTED.US_ID INTO @TBL
		VALUES	(
					@US_ID_MASTER,
					@US_NAME,
					@US_LOGIN,
					@US_NOTE,
					@US_DATE
				)

		SELECT	@US_ID = ID
		FROM	@TBL		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
	        ROLLBACK TRANSACTION
	END CATCH

	IF @@TRANCOUNT > 0
        COMMIT TRANSACTION
END

