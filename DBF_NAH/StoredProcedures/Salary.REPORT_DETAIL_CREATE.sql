USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[REPORT_DETAIL_CREATE]
	@PERIOD		SMALLINT,
	@COURIER	VARCHAR(MAX)
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
			COUR_ID, COUR_NAME, KGS, (1 - ISNULL(COEF, 0)) AS COEF,
			CT_NAME + ' (' + CASE
				WHEN CT_NAME = (SELECT CT_NAME FROM dbo.CityTable INNER JOIN dbo.CourierTable ON COUR_ID_CITY = CT_ID WHERE COUR_ID = a.COUR_ID) THEN '��'
				WHEN CT_NAME <> (SELECT CT_NAME FROM dbo.CityTable INNER JOIN dbo.CourierTable ON COUR_ID_CITY = CT_ID WHERE COUR_ID = a.COUR_ID) THEN '��'
				ELSE '-'
			END + ')' AS CT_NAME,
			CL_NAME, CLT_NAME, SYS_COUNT,
			CLIENT_TOTAL_PRICE, TO_COUNT, TO_PRICE, CPS_PERCENT, CPS_MIN, CPS_MAX, KOB, TO_CALC,
			CPS_PAY, CONVERT(INT, PAY) AS PAY, TO_PAY_RESULT, TO_PAY_HANDS, TO_RANGE, IsNull(d.TO_SERVICE_COEF, 1) AS TO_SERVICE_COEF,
			(
				SELECT COUNT(DISTINCT CT_NAME)
				FROM Salary.ServiceDetail z
				WHERE z.ID_SALARY = c.ID
			) AS COUR_COUNT,
			f.PR_ID, f.PR_NAME, UPDATES
		FROM
			dbo.CourierTable a
			INNER JOIN
				(
					SELECT Item
					FROM dbo.GET_TABLE_FROM_LIST(@COURIER, ',')

					UNION

					SELECT COUR_ID
					FROM dbo.CourierTable
					WHERE COUR_ID_TYPE = 2 AND COUR_ACTIVE = 1
				) AS b ON Item = COUR_ID
			INNER JOIN Salary.Service c ON ID_COURIER = COUR_ID
			INNER JOIN Salary.ServiceDetail d ON c.ID = d.ID_SALARY
			INNER JOIN dbo.ClientTypeTable e ON e.CLT_ID = d.ID_TYPE
			INNER JOIN dbo.PeriodTable f ON f.PR_ID = d.ID_PERIOD
		WHERE c.ID_PERIOD = @PERIOD

		ORDER BY COUR_NAME, CT_NAME, CL_NAME, TO_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
