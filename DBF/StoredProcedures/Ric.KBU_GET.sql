USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Ric].[KBU_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Ric].[KBU_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [Ric].[KBU_GET]
	@PR_ID	SMALLINT,
	@PR_ALG	SMALLINT
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

		IF dbo.PeriodDelta(@PR_ALG, 1) = @PR_ID
			SELECT RK_TOTAL AS KBU
			FROM Ric.KBU
			WHERE RK_ID_QUARTER = dbo.QuarterDelta(dbo.PeriodQuarter(@PR_ID), -1)
		ELSE
			SELECT RK_TOTAL AS KBU
			FROM Ric.KBU
			WHERE RK_ID_QUARTER = dbo.PeriodQuarter(@PR_ID)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Ric].[KBU_GET] TO rl_ric_kbu;
GO
