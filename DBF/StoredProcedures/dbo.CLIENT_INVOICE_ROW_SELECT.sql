USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:	24.03.2009
Описание:		строки таблицы счета-фактуры
*/

CREATE PROCEDURE [dbo].[CLIENT_INVOICE_ROW_SELECT]
	@invid INT
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
			INR_ID, DIS_ID, DIS_STR, INR_GOOD, INR_NAME, PR_ID, PR_NAME, INR_SUM, INR_ID_TAX, TX_NAME, TX_CAPTION,
			INR_TNDS, INR_SNDS, INR_SALL, INR_UNIT, INR_COUNT
			
		FROM 
			dbo.InvoiceRowTable A
			LEFT OUTER JOIN dbo.TaxTable B ON A.INR_ID_TAX = B.TX_ID 
			LEFT OUTER JOIN dbo.PeriodTable C ON A.INR_ID_PERIOD = C.PR_ID 
			LEFT OUTER JOIN dbo.DistrView WITH(NOEXPAND) ON DIS_ID = INR_ID_DISTR
		WHERE INR_ID_INVOICE = @invid
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
