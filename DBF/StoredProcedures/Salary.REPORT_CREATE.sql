USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[REPORT_CREATE]
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

		SELECT COUR_ID, COUR_NAME, ROUND((1 - ISNULL(COEF, 0)) * SUM(TO_PAY_RESULT), 2) AS COUR_TOTAL, 1 - ISNULL(COEF, 0) AS COEF
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
		WHERE c.ID_PERIOD = @PERIOD
		GROUP BY COUR_ID, COUR_NAME, COEF
		ORDER BY COUR_NAME
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Salary].[REPORT_CREATE] TO rl_courier_pay;
GO