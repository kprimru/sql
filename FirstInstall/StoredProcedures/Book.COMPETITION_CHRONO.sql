USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Book].[COMPETITION_CHRONO]
	@HLF_ID			UNIQUEIDENTIFIER,
	@CP_NAME		VARCHAR(100),
	@CP_COUNT		TINYINT,
	@CP_BONUS		MONEY,
	@CP_DATE		SMALLDATETIME,
	@CP_ID_MASTER	UNIQUEIDENTIFIER,
	@CP_END			SMALLDATETIME,
	@CP_ID			UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'COMPETITION', @CP_ID_MASTER, @OLD OUTPUT


	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
	DECLARE @MASTERID UNIQUEIDENTIFIER


	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE	Book.CompetitionDetail
		SET		CP_END	=	@CP_END,
				CP_REF	=	2
		WHERE	CP_ID	=	@CP_ID

		UPDATE	Book.Competition
		SET		CPMS_LAST	=	GETDATE()
		WHERE	CPMS_ID		=	@CP_ID_MASTER

		INSERT INTO
				Book.CompetitionDetail(
					CP_ID_MASTER,
					CP_ID_HALF,
					CP_NAME,
					CP_COUNT,
					CP_BONUS,
					CP_DATE
				)
		OUTPUT INSERTED.CP_ID INTO @TBL
		VALUES	(
					@CP_ID_MASTER,
					@HLF_ID,
					@CP_NAME,
					@CP_COUNT,
					@CP_BONUS,
					@CP_DATE
				)

		SELECT	@CP_ID = ID
		FROM	@TBL
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
	        ROLLBACK TRANSACTION
	END CATCH

	IF @@TRANCOUNT > 0
        COMMIT TRANSACTION

	EXEC Common.PROTOCOL_VALUE_GET 'COMPETITION', @CP_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'COMPETITION', '��������������� ���������', @CP_ID_MASTER, @OLD, @NEW

END

GO
GRANT EXECUTE ON [Book].[COMPETITION_CHRONO] TO rl_competition_u;
GO