USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  7.05.2009
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_FACT_INVOICE_SELECT]
	@clientid INT
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

		SELECT IFM_DATE, INS_ID, INS_DATE, SUM(INR_SALL) AS IF_TOTAL_PRICE
		FROM	dbo.InvoiceFactMasterTable	A	INNER JOIN
				dbo.InvoiceFactDetailTable	B	ON	B.IFD_ID_IFM=A.IFM_ID
		WHERE CL_ID = @clientid
		GROUP BY IFM_DATE, INS_ID, INS_DATE;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_FACT_INVOICE_SELECT] TO rl_invoice_p;
GO