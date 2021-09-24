USE [DBF_NAH]
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
ALTER PROCEDURE [dbo].[CLIENT_ACT_FACT_GET]
	@clientid INT,
	@date VARCHAR(100)
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

		DECLARE @d DATETIME
		SET @d = CONVERT(DATETIME, @date, 121)

		SELECT *
		FROM dbo.ActFactMasterTable
		WHERE AFM_DATE = @d AND CL_ID = @clientid
		ORDER BY CL_PSEDO, CL_ID, CO_NUM --, SYS_ORDER

		SELECT
			AFD_ID_AFM,
			DIS_ID, DIS_NUM, SYS_NAME, SYS_ORDER, TO_NUM,
			SUM(AD_PRICE) AS AD_PRICE, SUM(AD_TAX_PRICE) AS AD_TAX_PRICE,
			SUM(AD_TOTAL_PRICE) AS AD_TOTAL_PRICE,
			TX_PERCENT, TX_NAME, SO_ID, SO_BILL_STR, SO_INV_UNIT,
			SUM(AD_PAYED_PRICE) AS AD_PAYED_PRICE, TO_NAME
		FROM dbo.ActFactDetailTable
		INNER JOIN dbo.ActFactMasterTable  ON AFD_ID_AFM = AFM_ID
		WHERE AFM_DATE = @d AND CL_ID = @clientid
		GROUP BY AFD_ID_AFM,
			DIS_ID, DIS_NUM, SYS_NAME, SYS_ORDER, 
			TX_PERCENT, TX_NAME, SO_ID, SO_BILL_STR, SO_INV_UNIT, TO_NUM, TO_NAME, ACT_TO
		ORDER BY CASE WHEN ACT_TO = 1 THEN TO_NAME ELSE NULL END, SYS_ORDER, DIS_NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_ACT_FACT_GET] TO rl_act_p;
GO
