USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[HALF_CHRONO]
	@HLF_NAME		VARCHAR(50),
	@HLF_BEGIN_DATE	SMALLDATETIME,
	@HLF_END_DATE	SMALLDATETIME,
	@HLF_DATE		SMALLDATETIME,
	@HLF_ID_MASTER	UNIQUEIDENTIFIER,
	@HLF_END		SMALLDATETIME,
	@HLF_ID			UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'HALF', @HLF_ID_MASTER, @OLD OUTPUT


	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
	DECLARE @MASTERID UNIQUEIDENTIFIER


	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE	Common.HalfDetail
		SET		HLF_END	=	@HLF_END,
				HLF_REF	=	2
		WHERE	HLF_ID	=	@HLF_ID

		UPDATE	Common.Half
		SET		HLFMS_LAST	=	GETDATE()
		WHERE	HLFMS_ID	=	@HLF_ID_MASTER

		INSERT INTO
				Common.HalfDetail(
					HLF_ID_MASTER,
					HLF_NAME,
					HLF_BEGIN_DATE,
					HLF_END_DATE,
					HLF_DATE
				)
		OUTPUT INSERTED.HLF_ID INTO @TBL
		VALUES	(
					@HLF_ID_MASTER,
					@HLF_NAME,
					@HLF_BEGIN_DATE,
					@HLF_END_DATE,
					@HLF_DATE
				)

		SELECT	@HLF_ID = ID
		FROM	@TBL
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
	        ROLLBACK TRANSACTION
	END CATCH

	IF @@TRANCOUNT > 0
        COMMIT TRANSACTION

	EXEC Common.PROTOCOL_VALUE_GET 'HALF', @HLF_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'HALF', '��������������� ���������', @HLF_ID_MASTER, @OLD, @NEW

END

GO
GRANT EXECUTE ON [Common].[HALF_CHRONO] TO rl_half_u;
GO
