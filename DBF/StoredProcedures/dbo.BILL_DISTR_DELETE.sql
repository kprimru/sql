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

CREATE PROCEDURE [dbo].[BILL_DISTR_DELETE]
	@blid VARCHAR(MAX)
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

		IF OBJECT_ID('tempdb..#bill') IS NOT NULL
			DROP TABLE #bill

		CREATE TABLE #bill
			(
				billid INT
			)

		IF @blid IS NOT NULL
			BEGIN
				--парсить строчку и выбирать нужные значения
				INSERT INTO #bill
					SELECT DISTINCT * FROM dbo.GET_TABLE_FROM_LIST(@blid, ',')
			END

		DELETE FROM dbo.SaldoTable
		WHERE SL_ID_BILL_DIS IN	(SELECT billid FROM #bill)

		DELETE FROM dbo.BillDistrTable
		WHERE BD_ID IN (SELECT billid FROM #bill)

		IF OBJECT_ID('tempdb..#bill') IS NOT NULL
			DROP TABLE #bill
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END






