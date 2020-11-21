USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DBF_CACHE_REFRESH]
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

		DELETE FROM [DBF].[Sync.DistrFinancing];

		TRUNCATE TABLE dbo.DBFAct;

		INSERT INTO dbo.DBFAct(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, AD_TOTAL_PRICE)
		SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, AD_TOTAL_PRICE
		FROM [DBF].[dbo.ActAllIXView] --WITH(NOEXPAND);

		TRUNCATE TABLE dbo.DBFBill;

		INSERT INTO dbo.DBFBill(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, BD_TOTAL_PRICE)
		SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, BD_TOTAL_PRICE
		FROM [DBF].[dbo.BillAllIXView] --WITH(NOEXPAND);

		TRUNCATE TABLE dbo.DBFIncome;

		INSERT INTO dbo.DBFIncome(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, ID_PRICE)
		SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, ID_PRICE
		FROM [DBF].[dbo.IncomeAllIXView] --WITH(NOEXPAND);

		TRUNCATE TABLE dbo.DBFIncomeDate;

		INSERT INTO dbo.DBFIncomeDate(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, IN_DATE)
		SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, IN_DATE
		FROM [DBF].[dbo.IncomeDateIXView] --WITH(NOEXPAND);

		TRUNCATE TABLE dbo.DBFBillRest;

		INSERT INTO dbo.DBFBillRest(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, BD_REST)
		SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, BD_REST
		FROM [DBF].[dbo.BillAllRestView] --WITH(NOEXPAND);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
