USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[PROCESSOR_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[PROCESSOR_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [USR].[PROCESSOR_SELECT]
	@FILTER	VARCHAR(100) = NULL
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

		SELECT PRC_ID, PRC_NAME, PRC_FREQ, PRC_CORE, PF_NAME
		FROM
			USR.Processor
			LEFT OUTER JOIN USR.ProcessorFamily ON PF_ID = PRC_ID_FAMILY
		WHERE @FILTER IS NULL
			OR PRC_NAME LIKE @FILTER
		ORDER BY PRC_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[PROCESSOR_SELECT] TO rl_processor_r;
GO
