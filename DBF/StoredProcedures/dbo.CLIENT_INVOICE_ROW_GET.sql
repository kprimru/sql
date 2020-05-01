USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:	1.04.2009
Описание:		строка таблицы счета-фактуры
*/

ALTER PROCEDURE [dbo].[CLIENT_INVOICE_ROW_GET]
	@rowid INT
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
			INR_ID, DIS_ID, DIS_STR, INR_GOOD, INR_NAME, INR_SUM, 
			INR_ID_TAX, INR_TNDS, INR_SNDS, INR_SALL, INR_UNIT, INR_COUNT,
			PR_ID, PR_NAME
		FROM 
			dbo.InvoiceRowTable 
			LEFT OUTER JOIN dbo.DistrView WITH(NOEXPAND) ON INR_ID_DISTR = DIS_ID 
			LEFT OUTER JOIN dbo.PeriodTable ON INR_ID_PERIOD = PR_ID
		WHERE INR_ID = @rowid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_INVOICE_ROW_GET] TO rl_invoice_r;
GO