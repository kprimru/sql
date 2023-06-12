USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Salary].[SERVICE_SALARY_DISTR_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Salary].[SERVICE_SALARY_DISTR_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Salary].[SERVICE_SALARY_DISTR_SELECT]
	@ID			UNIQUEIDENTIFIER
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

		SELECT
			ID, CLIENT, DISTR_STR, OPER, PRICE_OLD, PRICE_NEW, PRICE_NEW - PRICE_OLD AS PRICE_DELTA,
			WEIGHT_OLD, WEIGHT_NEW, WEIGHT_NEW - WEIGHT_OLD AS WEIGHT_DELTA
		FROM
			Salary.ServiceDistr
		WHERE ID_SALARY = @ID
		ORDER BY CLIENT, DISTR_STR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Salary].[SERVICE_SALARY_DISTR_SELECT] TO rl_salary;
GO
