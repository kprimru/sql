USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Salary].[SERVICE_SALARY_CLIENT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Salary].[SERVICE_SALARY_CLIENT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Salary].[SERVICE_SALARY_CLIENT_SELECT]
	@SALARY		UNIQUEIDENTIFIER
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

		DECLARE @SALARY_PREV	UNIQUEIDENTIFIER
		DECLARE @SERVICE		INT
		DECLARE @PERIOD			UNIQUEIDENTIFIER
		DECLARE @PERIOD_PREV	UNIQUEIDENTIFIER

		SELECT @SERVICE = ID_SERVICE, @PERIOD = ID_MONTH
		FROM Salary.Service
		WHERE ID = @SALARY

		SELECT @PERIOD_PREV = ID
		FROM Common.Period
		WHERE TYPE = 2
			AND START = DATEADD(MONTH, -1, (SELECT START FROM Common.Period WHERE ID = @PERIOD))


		SELECT @SALARY_PREV = ID
		FROM Salary.Service
		WHERE ID_SERVICE = @SERVICE
			AND ID_MONTH = @PERIOD_PREV

		SELECT
			a.ID, ID_CLIENT, ClientFullName,
			(
				SELECT COUNT(*)
				FROM
					Salary.ServiceClient z
					INNER JOIN Salary.Service y ON z.ID_SALARY = y.ID
				WHERE y.ID_MONTH = @PERIOD_PREV
					AND y.ID_SERVICE = c.ID_SERVICE
					AND a.ID_CLIENT = z.ID_CLIENT
			) AS FLAG
		FROM
			Salary.ServiceClient a
			INNER JOIN dbo.ClientTable b ON a.ID_CLIENT = ClientID
			INNER JOIN Salary.Service c ON a.ID_SALARY = c.ID
		WHERE c.ID = @SALARY


		UNION ALL

		SELECT
			a.ID, ID_CLIENT, ClientFullName,
			-1 AS FLAG
		FROM
			Salary.ServiceClient a
			INNER JOIN dbo.ClientTable b ON a.ID_CLIENT = ClientID
			INNER JOIN Salary.Service c ON a.ID_SALARY = c.ID
		WHERE c.ID = @SALARY_PREV
			AND NOT EXISTS
				(
					SELECT COUNT(*)
					FROM
						Salary.ServiceClient z
						INNER JOIN Salary.Service y ON z.ID_SALARY = y.ID
					WHERE y.ID_MONTH = @PERIOD
						AND y.ID_SERVICE = c.ID_SERVICE
						AND a.ID_CLIENT = z.ID_CLIENT
				)

		ORDER BY ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Salary].[SERVICE_SALARY_CLIENT_SELECT] TO rl_salary;
GO
