USE [DBF_NAH]
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
ALTER PROCEDURE [dbo].[INVOICE_YEAR_HOLE_SELECT]
	@year VARCHAR(5),
	@orgid SMALLINT
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

		DECLARE @min BIGINT
		DECLARE @max BIGINT
		DECLARE @row BIGINT

		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp

		CREATE TABLE #temp
			(
				INS_NUM BIGINT
			)

		SELECT @min = MIN(INS_NUM), @max = MAX(INS_NUM)
		FROM dbo.InvoiceSaleTable
		WHERE INS_NUM_YEAR = @year AND INS_ID_ORG = @orgid

		SELECT @row = @min + 1

		WHILE @row < @max
		BEGIN
			INSERT INTO #temp SELECT @row
			SET @row = @row + 1
		END
		/*
		SELECT @year, INS_NUM, @orgid
		FROM #temp a EXCEPT
			SELECT @year, INS_NUM, @orgid
			FROM dbo.InvoiceSaleTable
			WHERE INS_ID_ORG = @orgid
			*/

		SELECT @year, INS_NUM, @orgid
		FROM #temp a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.InvoiceSaleTable b
				WHERE INS_ID_ORG = @orgid
					AND b.INS_NUM = a.INS_NUM
					AND INS_NUM_YEAR = @year
			)

		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[INVOICE_YEAR_HOLE_SELECT] TO rl_invoice_r;
GO
