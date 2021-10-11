USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[SERVICE_SELECT]
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

		SELECT ID, PR_DATE, COUR_NAME, PR_ID, COUR_ID, (1 - ISNULL(COEF, 0)) * (SELECT SUM(TO_PAY_RESULT) FROM Salary.ServiceDetail d WHERE a.ID = d.ID_SALARY) AS COUR_TOTAL, COEF
		FROM
			Salary.Service a
			INNER JOIN
				(
					SELECT COUR_NAME, COUR_ID
					FROM
						dbo.CourierTable b
						INNER JOIN dbo.GET_TABLE_FROM_LIST(@COURIER, ',') ON COUR_ID = ITEM

					UNION

					SELECT COUR_NAME, COUR_ID
					FROM dbo.CourierTable
				) AS b ON a.ID_COURIER = b.COUR_ID
			INNER JOIN dbo.PeriodTable c ON c.PR_ID = a.ID_PERIOD
		WHERE (ID_PERIOD = @PERIOD OR @PERIOD IS NULL)
		ORDER BY PR_DATE DESC, COUR_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Salary].[SERVICE_SELECT] TO public;
GRANT EXECUTE ON [Salary].[SERVICE_SELECT] TO rl_courier_pay;
GO
