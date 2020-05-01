USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:		
*/

ALTER PROCEDURE [dbo].[AUDIT_FINANCING_SELECT]
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

		DECLARE @PR SMALLINT
		SET @PR = dbo.GET_PERIOD_BY_DATE(GETDATE())

		SELECT CL_ID, CL_PSEDO, DIS_ID, DIS_STR, FIN_ERROR
		FROM dbo.AuditFinancingView
		/*
		UNION ALL
		
		SELECT CL_ID, CL_PSEDO, DIS_ID, DIS_STR, 'Не сформирован счет по начислению за текущий месяц' AS FIN_ERROR
		FROM 
			dbo.ClientTable INNER JOIN
			dbo.ClientDistrTable ON CD_ID_CLIENT = CL_ID INNER JOIN
			dbo.DistrView ON DIS_ID = CD_ID_DISTR INNER JOIN
			dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE INNER JOIN 
			dbo.DistrFinancingTable ON DF_ID_DISTR = DIS_ID INNER JOIN
			dbo.PeriodTable ON DF_ID_PERIOD = PR_ID
		WHERE PR_DATE <= GETDATE() AND DSS_REPORT = 1 AND SYS_ID_SO = 1 AND DF_MON_COUNT <> 0
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.BillIXView WITH(NOEXPAND)
					WHERE BD_ID_DISTR = DIS_ID 
						AND BL_ID_CLIENT = CL_ID
						AND BL_ID_PERIOD = @PR
				)
		*/
		
		ORDER BY CL_PSEDO, CL_ID, DIS_STR
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[AUDIT_FINANCING_SELECT] TO rl_audit_fin;
GRANT EXECUTE ON [dbo].[AUDIT_FINANCING_SELECT] TO rl_audit_financing_r;
GO