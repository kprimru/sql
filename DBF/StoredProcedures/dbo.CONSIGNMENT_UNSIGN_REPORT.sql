USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONSIGNMENT_UNSIGN_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONSIGNMENT_UNSIGN_REPORT]  AS SELECT 1')
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[CONSIGNMENT_UNSIGN_REPORT]
	@consdate SMALLDATETIME
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
			CL_ID, CL_PSEDO, COUR_NAME, CSG_DATE, PR_DATE
		FROM
			dbo.ClientCourView INNER JOIN
			dbo.ConsignmentPeriodView ON CSG_ID_CLIENT = CL_ID INNER JOIN
			dbo.PeriodTable ON PR_ID = CSG_ID_PERIOD
		WHERE CSG_SIGN IS NULL
			AND CSG_DATE <= @consdate
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
GRANT EXECUTE ON [dbo].[CONSIGNMENT_UNSIGN_REPORT] TO rl_consignment_w;
GO
