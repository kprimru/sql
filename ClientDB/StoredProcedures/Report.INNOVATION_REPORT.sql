USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[INNOVATION_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[INNOVATION_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[INNOVATION_REPORT]
	@PARAM	NVARCHAR(MAX) = NULL
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

		SELECT EXECUTE_DATE_S AS [Дата исполнения], DETAIL_DATA AS [Описание], EXECUTOR_NOTE AS [Примечание исполнителя]
		FROM dbo.TaskDBView
		ORDER BY EXECUTE_DATE_S DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH

END
GO
GRANT EXECUTE ON [Report].[INNOVATION_REPORT] TO rl_report;
GO
