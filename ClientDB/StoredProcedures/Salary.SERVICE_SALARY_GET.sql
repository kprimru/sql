USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Salary].[SERVICE_SALARY_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Salary].[SERVICE_SALARY_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [Salary].[SERVICE_SALARY_GET]
	@ID	UNIQUEIDENTIFIER
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

		SELECT ID_SERVICE, ID_MONTH, ID_POSITION, MANAGER_RATE, INSURANCE
		FROM Salary.Service
		WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Salary].[SERVICE_SALARY_GET] TO rl_salary;
GO
