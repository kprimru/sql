USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Install].[INSTALL_ACT_CHRONO]
	@IA_NAME		VARCHAR(50),
	@IA_NORM		BIT,
	@IA_DATE		SMALLDATETIME,
	@IA_ID_MASTER	UNIQUEIDENTIFIER,
	@IA_END			SMALLDATETIME,
	@IA_ID			UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'INSTALL_ACT', @IA_ID_MASTER, @OLD OUTPUT


	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
	DECLARE @MASTERID UNIQUEIDENTIFIER


	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE	Install.InstallActDetail
		SET		IA_END	=	@IA_END,
				IA_REF	=	2
		WHERE	IA_ID	=	@IA_ID	

		UPDATE	Install.InstallAct
		SET		IAMS_LAST	=	GETDATE()
		WHERE	IAMS_ID		=	@IA_ID_MASTER

		INSERT INTO 
				Install.InstallActDetail(
					IA_ID_MASTER,
					IA_NAME,
					IA_NORM,					
					IA_DATE
				)
		OUTPUT INSERTED.IA_ID INTO @TBL
		VALUES	(
					@IA_ID_MASTER,
					@IA_NAME,
					@IA_NORM,
					@IA_DATE
				)

		SELECT	@IA_ID = ID
		FROM	@TBL		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
	        ROLLBACK TRANSACTION
	END CATCH

	IF @@TRANCOUNT > 0
        COMMIT TRANSACTION

	EXEC Common.PROTOCOL_VALUE_GET 'INSTALL_ACT', @IA_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'INSTALL_ACT', '��������������� ���������', @IA_ID_MASTER, @OLD, @NEW
END
