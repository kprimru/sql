USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			
Дата создания:  	
Описание:		
*/

ALTER PROCEDURE [dbo].[CLIENT_BILL_FACT_ROW_ADD]	
	@BFD_ID_BFM INT, 
	@BILL_STR VARCHAR(150), 
	@TX_PERCENT DECIMAL(8, 4), 
	@TX_NAME VARCHAR(50), 
	@SYS_NAME VARCHAR(250), 
	@SYS_ORDER SMALLINT, 
	@DIS_ID INT, 
	@DIS_NUM VARCHAR(20), 
	@PR_ID SMALLINT,	
	@PR_MONTH VARCHAR(50), 
	@PR_DATE SMALLDATETIME, 
	@BD_UNPAY MONEY,	
	@BD_TAX_UNPAY MONEY, 
	@BD_TOTAL_UNPAY MONEY
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

		INSERT INTO dbo.BillFactDetailTable(BFD_ID_BFM, BILL_STR, TX_PERCENT, TX_NAME, SYS_NAME, SYS_ORDER, DIS_ID, DIS_NUM, PR_ID, PR_MONTH, PR_DATE, BD_UNPAY, BD_TAX_UNPAY, BD_TOTAL_UNPAY)
		VALUES(@BFD_ID_BFM, @BILL_STR, @TX_PERCENT, @TX_NAME, @SYS_NAME, @SYS_ORDER, @DIS_ID, @DIS_NUM, @PR_ID, @PR_MONTH, @PR_DATE, @BD_UNPAY, @BD_TAX_UNPAY, @BD_TOTAL_UNPAY)
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_BILL_FACT_ROW_ADD] TO rl_bill_w;
GO