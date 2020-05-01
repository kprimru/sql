USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[SERVICE_WEIGHT_BALANS]
	@SERVICE		INT,
	@MONTH			UNIQUEIDENTIFIER,
	@CURRENT		BIT,
	@DYNAMIC		BIT
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

		DECLARE @MONTH_DATE SMALLDATETIME

		SELECT @MONTH_DATE = START
		FROM Common.Period
		WHERE ID = @MONTH

		IF @DYNAMIC = 1
			SELECT c.NAME, SUM(WEIGHT_NEW - WEIGHT_OLD) AS WEIGHT_DELTA
			FROM
				Salary.Service a
				INNER JOIN Salary.ServiceDistr b ON a.ID = b.ID_SALARY
				INNER JOIN Common.Period c ON a.ID_MONTH = c.ID AND c.TYPE = 2
			WHERE a.ID_SERVICE = @SERVICE AND c.START >= @MONTH_DATE
			GROUP BY c.NAME, c.START
			ORDER BY c.START DESC
		ELSE
		BEGIN
			IF @CURRENT = 1
			BEGIN
				IF OBJECT_ID('tempdb..#distr') IS NOT NULL
					DROP TABLE #distr

				CREATE TABLE #distr
					(
						CHECKED			BIT,
						ID_HOST			INT,
						DISTR			INT,
						COMP			INT,
						DISTR_STR		NVARCHAR(64),
						CLIENT			NVARCHAR(128),
						OPER			NVARCHAR(128),
						OPER_NOTE		NVARCHAR(128),
						WEIGHT_OLD		DECIMAL(8, 4),
						WEIGHT_NEW		DECIMAL(8, 4),
						WEIGHT_DELTA	DECIMAL(8, 4),
						PRICE_OLD		MONEY,
						PRICE_NEW		MONEY,
						PRICE_DELTA		MONEY,
						ServiceID		INT,
						ServiceName		NVARCHAR(128)
					)

				INSERT INTO #distr
					EXEC Salary.SERVICE_SALARY_DISTR_IMPORT_SELECT @MONTH, @SERVICE

				SELECT CLIENT, DISTR_STR, OPER, OPER_NOTE, WEIGHT_NEW - WEIGHT_OLD AS WEIGHT_DELTA
				FROM #distr
				WHERE CHECKED = 1

				IF OBJECT_ID('tempdb..#distr') IS NOT NULL
					DROP TABLE #distr
			END
			ELSE
			BEGIN
				SELECT CLIENT, DISTR_STR, OPER, OPER_NOTE, WEIGHT_NEW - WEIGHT_OLD AS WEIGHT_DELTA
				FROM
					Salary.Service a
					INNER JOIN Salary.ServiceDistr b ON a.ID = b.ID_SALARY
				WHERE a.ID_SERVICE = @SERVICE AND a.ID_MONTH = @MONTH
			END
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Salary].[SERVICE_WEIGHT_BALANS] TO rl_service_weight;
GO