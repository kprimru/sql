USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SATISFACTION_TYPE_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SATISFACTION_TYPE_UPDATE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SATISFACTION_TYPE_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	VARCHAR(50),
	@RESULT	BIT
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

		UPDATE	dbo.SatisfactionType
		SET		STT_NAME	=	@NAME,
				STT_RESULT	=	@RESULT
		WHERE	STT_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SATISFACTION_TYPE_UPDATE] TO rl_satisfaction_type_u;
GO
