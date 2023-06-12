USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Training].[SEMINAR_SIGN_UNRESERVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Training].[SEMINAR_SIGN_UNRESERVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Training].[SEMINAR_SIGN_UNRESERVE]
	@ID	UNIQUEIDENTIFIER,
	@TSC_ID	UNIQUEIDENTIFIER,
	@OUT_ID	UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @CLIENT		INT
		DECLARE @SURNAME	VARCHAR(150)
		DECLARE @NAME		VARCHAR(150)
		DECLARE @PATRON		VARCHAR(150)
		DECLARE @POS		VARCHAR(150)
		DECLARE @PHONE		VARCHAR(150)
		DECLARE @NOTE		VARCHAR(MAX)

		SELECT @CLIENT = SR_ID_CLIENT, @SURNAME = SR_SURNAME, @NAME = SR_NAME, @PATRON = SR_PATRON, @POS = SR_POS, @PHONE = SR_PHONE, @NOTE = SR_NOTE
		FROM Training.SeminarReserve
		WHERE SR_ID = @ID

		EXEC Training.SEMINAR_SIGN_INSERT @TSC_ID, @CLIENT, @SURNAME, @NAME, @PATRON, @POS, @PHONE, @NOTE, 0, @OUT_ID OUTPUT

		DELETE FROM Training.SeminarReserve WHERE SR_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Training].[SEMINAR_SIGN_UNRESERVE] TO rl_training_unreserve;
GO
