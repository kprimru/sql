USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  25.05.2009
Описание:
*/
ALTER PROCEDURE [dbo].[BILL_FACT_SELECT]
	@date VARCHAR(100),
	@courid VARCHAR(MAX) = NULL
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

		IF OBJECT_ID('tempdb..#cour') IS NOT NULL
			DROP TABLE #cour

		CREATE TABLE #cour
			(
				COUR_ID SMALLINT
			)

		IF @courid IS NULL
			INSERT INTO #cour (COUR_ID)
				SELECT COUR_ID
				FROM dbo.CourierTable
		ELSE
			INSERT INTO #cour
				SELECT * FROM dbo.GET_TABLE_FROM_LIST(@courid, ',')

		SET NOCOUNT ON;
		DECLARE @d DATETIME
		SET @d = CONVERT(DATETIME, @date, 121)

		SELECT dbo.BillFactMasterTable.*
		FROM
			dbo.BillFactMasterTable INNER JOIN
			#cour ON COUR_ID =
				(SELECT TOP 1 TO_ID_COUR FROM dbo.TOTable WHERE TO_ID_CLIENT = CL_ID ORDER BY TO_ID_COUR)
		WHERE BFM_DATE = @d
		ORDER BY COUR_ID

		SELECT dbo.BillFactDetailTable.*
		FROM
			dbo.BillFactDetailTable INNER JOIN
			dbo.BillFactMasterTable ON BFD_ID_BFM = BFM_ID INNER JOIN
			#cour ON COUR_ID =
				(SELECT TOP 1 TO_ID_COUR FROM dbo.TOTable WHERE TO_ID_CLIENT = CL_ID ORDER BY TO_ID_COUR)
		WHERE BFM_DATE = @d
		ORDER BY CO_NUM, SYS_ORDER, DIS_NUM, PR_DATE

		IF OBJECT_ID('tempdb..#cour') IS NOT NULL
			DROP TABLE #cour

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[BILL_FACT_SELECT] TO rl_bill_p;
GO