USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[SYSTEM_NET_COEF_SELECT]
	@ACTIVE BIT
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

		SELECT SNCC_ID, SN_NAME, PR_DATE, SNCC_VALUE, SNCC_SUBHOST, SNCC_ROUND, SNCC_ACTIVE
		FROM
			dbo.SystemNetCoef a INNER JOIN
			dbo.SystemNetTable b ON a.SNCC_ID_SN = b.SN_ID INNER JOIN
			dbo.PeriodTable c ON c.PR_ID = a.SNCC_ID_PERIOD
		WHERE SNCC_ACTIVE = ISNULL(@active, SNCC_ACTIVE)-- AND DATEPART(YEAR, PR_DATE) = '2011'
		ORDER BY PR_DATE DESC, SNCC_VALUE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_NET_COEF_SELECT] TO rl_system_net_w;
GO
