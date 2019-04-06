USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Clients].[VENDOR_CHRONO]
	@VD_NAME		VARCHAR(50),
	@VD_DATE		SMALLDATETIME,
	@VD_ID_MASTER	UNIQUEIDENTIFIER,
	@VD_END			SMALLDATETIME,
	@VD_ID			UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'VENDOR', @VD_ID_MASTER, @OLD OUTPUT


	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
	DECLARE @MASTERID UNIQUEIDENTIFIER


	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE	Clients.VendorDetail
		SET		VD_END	=	@VD_END,
				VD_REF	=	2
		WHERE	VD_ID	=	@VD_ID	

		UPDATE	Clients.Vendor
		SET		VDMS_LAST	=	GETDATE()
		WHERE	VDMS_ID		=	@VD_ID_MASTER

		INSERT INTO 
				Clients.VendorDetail(
					VD_ID_MASTER,
					VD_NAME,
					VD_DATE
				)
		OUTPUT INSERTED.VD_ID INTO @TBL
		VALUES	(
					@VD_ID_MASTER,
					@VD_NAME,
					@VD_DATE
				)

		SELECT	@VD_ID = ID
		FROM	@TBL		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
	        ROLLBACK TRANSACTION
	END CATCH

	IF @@TRANCOUNT > 0
        COMMIT TRANSACTION

	EXEC Common.PROTOCOL_VALUE_GET 'VENDOR', @VD_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'VENDOR', '��������������� ���������', @VD_ID_MASTER, @OLD, @NEW

END

