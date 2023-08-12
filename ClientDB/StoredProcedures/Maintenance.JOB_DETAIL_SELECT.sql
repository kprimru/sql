USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[JOB_DETAIL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[JOB_DETAIL_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Maintenance].[JOB_DETAIL_SELECT]
	@ID			INT
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

		SELECT TOP(100) *, DATEDIFF(ms, START, FINISH) AS EX_TIME
		FROM Maintenance.Jobs
		WHERE	Type_Id=@ID
		ORDER BY START DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END;GO
GRANT EXECUTE ON [Maintenance].[JOB_DETAIL_SELECT] TO rl_job_detail_r;
GO
