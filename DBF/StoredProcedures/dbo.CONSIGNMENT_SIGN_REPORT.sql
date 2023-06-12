USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONSIGNMENT_SIGN_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONSIGNMENT_SIGN_REPORT]  AS SELECT 1')
GO
/*
Автор:
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[CONSIGNMENT_SIGN_REPORT]
	--@actbegin SMALLDATETIME,
	--@actend SMALLDATETIME,
	@consdate SMALLDATETIME,
	@consperiod SMALLINT,
	@courlist VARCHAR(MAX) = NULL
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

		DECLARE @cour TABLE (CR_ID SMALLINT)

		IF @courlist IS NULL
			INSERT INTO @cour
				SELECT COUR_ID
				FROM dbo.CourierTable
		ELSE
			INSERT INTO @cour
				SELECT *
				FROM dbo.GET_TABLE_FROM_LIST(@courlist, ',')

		/*
		SELECT
			CL_ID, CL_PSEDO, COUR_NAME, ACT_DATE, ACT_SIGN
		FROM
			dbo.ClientCourView INNER JOIN
			dbo.ActTable ON ACT_ID_CLIENT = CL_ID INNER JOIN
			@cour ON CR_ID = COUR_ID
		WHERE ACT_DATE BETWEEN @actbegin AND @actend
		ORDER BY COUR_NAME, CL_PSEDO, CL_ID, ACT_DATE
		*/

		SELECT
			DISTINCT CSG_ID, CL_ID, CL_PSEDO, COUR_NAME, DSS_NAME, DSS_REPORT, CSG_DATE, CSG_SIGN
		FROM 
			dbo.TOStatusView a INNER JOIN
			dbo.DistrServiceStatusTable b ON a.DSS_ID = b.DSS_ID INNER JOIN
			dbo.CourierTable ON COUR_ID = TO_ID_COUR INNER JOIN
			@cour ON CR_ID = COUR_ID INNER JOIN
			dbo.ClientTable ON CL_ID = TO_ID_CLIENT	INNER JOIN
			dbo.TODistrTable ON TO_ID = TD_ID_TO LEFT OUTER JOIN
			dbo.ConsignmentPeriodView ON CSG_ID_CLIENT = CL_ID LEFT OUTER JOIN
			dbo.ConsignmentDetailTable ON CSD_ID_DISTR = TD_ID_DISTR AND CSG_ID = CSD_ID_CONS
		WHERE (CSG_DATE <= @consdate OR CSG_DATE IS NULL)
			AND (CSG_ID_PERIOD = @consperiod OR CSG_ID_PERIOD IS NULL)
			AND DSS_ACT = 1
		ORDER BY COUR_NAME, CL_PSEDO, CL_ID, CSG_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_SIGN_REPORT] TO rl_consignment_w;
GO
