USE [DBF_NAH]
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
ALTER PROCEDURE [dbo].[CONSIGNMENT_FACT_SELECT]
	@date VARCHAR(100),
	@courid VARCHAR(1000) = NULL
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

		SELECT ConsignmentFactMasterTable.*
		FROM
			dbo.ConsignmentFactMasterTable INNER JOIN
			#cour ON COUR_ID =
				(SELECT TOP 1 TO_ID_COUR FROM dbo.TOTable WHERE TO_ID_CLIENT = CL_ID ORDER BY TO_ID_COUR)
		WHERE CFM_FACT_DATE = @d
		ORDER BY COUR_ID

		SELECT ConsignmentFactDetailTable.*
		FROM
			dbo.ConsignmentFactDetailTable INNER JOIN
			dbo.ConsignmentFactMasterTable ON CFD_ID_CFM = CFM_ID INNER JOIN
			#cour ON COUR_ID =
				(SELECT TOP 1 TO_ID_COUR FROM dbo.TOTable WHERE TO_ID_CLIENT = CL_ID ORDER BY TO_ID_COUR)
		WHERE CFM_FACT_DATE = @d
		ORDER BY CSD_NUM

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
GRANT EXECUTE ON [dbo].[CONSIGNMENT_FACT_SELECT] TO rl_consignment_p;
GO