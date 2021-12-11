USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SATISFACTION_QUESTION_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SATISFACTION_QUESTION_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SATISFACTION_QUESTION_UPDATE]
	@ID	UNIQUEIDENTIFIER,
	@TEXT	VARCHAR(500),
	@SINGLE	BIT,
	@BOLD	BIT,
	@ORDER	INT,
	@ACTIVE	BIT
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

		UPDATE dbo.SatisfactionQuestion
		SET SQ_TEXT = @TEXT,
			SQ_SINGLE = @SINGLE,
			SQ_BOLD = @BOLD,
			SQ_ORDER = @ORDER,
			SQ_ACTIVE = @ACTIVE
		WHERE SQ_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SATISFACTION_QUESTION_UPDATE] TO rl_satisfaction_u;
GO
