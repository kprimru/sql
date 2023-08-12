USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SATISFACTION_TYPE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SATISFACTION_TYPE_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SATISFACTION_TYPE_SELECT]
	@FILTER	VARCHAR(100) = NULL OUTPUT
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

		SELECT STT_ID, STT_NAME, STT_RESULT
		FROM dbo.SatisfactionType
		WHERE @FILTER IS NULL
			OR STT_NAME LIKE @FILTER
		ORDER BY STT_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SATISFACTION_TYPE_SELECT] TO rl_satisfaction_type_r;
GO
