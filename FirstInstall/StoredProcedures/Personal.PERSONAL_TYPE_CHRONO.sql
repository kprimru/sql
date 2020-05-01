USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[PERSONAL_TYPE_CHRONO]
	@PT_NAME		VARCHAR(50),
	@PT_ALIAS		VARCHAR(50),
	@PT_DATE		SMALLDATETIME,
	@PT_ID_MASTER	UNIQUEIDENTIFIER,
	@PT_END			SMALLDATETIME,
	@PT_ID			UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL_TYPE', @PT_ID_MASTER, @OLD OUTPUT


	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
	DECLARE @MASTERID UNIQUEIDENTIFIER

	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE	Personal.PersonalTypeDetail
		SET		PT_END	=	@PT_END,
				PT_REF	=	2
		WHERE	PT_ID	=	@PT_ID

		INSERT INTO
				Personal.PersonalTypeDetail(
					PT_ID_MASTER,
					PT_NAME,
					PT_ALIAS,
					PT_DATE
				)
		OUTPUT INSERTED.PT_ID INTO @TBL
		VALUES	(
					@PT_ID_MASTER,
					@PT_NAME,
					@PT_ALIAS,
					@PT_DATE
				)

		SELECT	@PT_ID = ID
		FROM	@TBL
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
	        ROLLBACK TRANSACTION
	END CATCH

	IF @@TRANCOUNT > 0
        COMMIT TRANSACTION

	EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL_TYPE', @PT_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'PERSONAL_TYPE', '��������������� ���������', @PT_ID_MASTER, @OLD, @NEW

END

GRANT EXECUTE ON [Personal].[PERSONAL_TYPE_CHRONO] TO rl_personal_type_u;
GO