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

ALTER PROCEDURE [dbo].[INVOICE_HOLE_SELECT]
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

		IF OBJECT_ID('tempdb..#year') IS NOT NULL
			DROP TABLE #year

		CREATE TABLE #year
			(
				INS_NUM_YEAR VARCHAR(5),
				INS_ID_ORG SMALLINT
			)

		INSERT INTO #year
			SELECT DISTINCT INS_NUM_YEAR, INS_ID_ORG
			FROM dbo.InvoiceSaleTable
			WHERE INS_DATE >= DATEADD(YEAR, -2, GETDATE())

		IF OBJECT_ID('tempdb..#holes') IS NOT NULL
			DROP TABLE #holes

		CREATE TABLE #holes
			(
				INS_NUM_YEAR VARCHAR(5),
				INS_NUM INT,
				INS_ID_ORG SMALLINT
			)


		DECLARE INS_YEAR CURSOR LOCAL FOR
			SELECT INS_NUM_YEAR, INS_ID_ORG
			FROM #year

		OPEN INS_YEAR

		DECLARE @insyear VARCHAR(5)
		DECLARE @orgid SMALLINT

		FETCH NEXT FROM INS_YEAR
			INTO @insyear, @orgid

		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO #holes EXEC dbo.INVOICE_YEAR_HOLE_SELECT @insyear, @orgid

			FETCH NEXT FROM INS_YEAR
				INTO @insyear, @orgid
		END

		SELECT (CONVERT(VARCHAR, INS_NUM) + '/' + INS_NUM_YEAR) AS INS_FULL_NUM, ORG_PSEDO
		FROM
			#holes INNER JOIN
			dbo.OrganizationTable ON ORG_ID = INS_ID_ORG
		ORDER BY ORG_PSEDO, INS_NUM_YEAR, INS_NUM

		CLOSE INS_YEAR
		DEALLOCATE INS_YEAR

		IF OBJECT_ID('tempdb..#holes') IS NOT NULL
			DROP TABLE #holes

		IF OBJECT_ID('tempdb..#year') IS NOT NULL
			DROP TABLE #year

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[INVOICE_HOLE_SELECT] TO rl_invoice_r;
GO