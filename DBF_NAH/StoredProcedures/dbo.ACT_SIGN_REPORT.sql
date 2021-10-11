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
ALTER PROCEDURE [dbo].[ACT_SIGN_REPORT]
	--@actbegin SMALLDATETIME,
	--@actend SMALLDATETIME,
	@actdate SMALLDATETIME,
	@actperiod SMALLINT,
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

		SELECT DISTINCT
			ACT_ID, a.CL_ID, a.CL_PSEDO, COUR_NAME, DSS_NAME, DSS_REPORT, ACT_DATE, ACT_SIGN
		FROM
			dbo.ActPeriodView INNER JOIN
			dbo.ClientTable a ON ACT_ID_CLIENT = CL_ID INNER JOIN
			dbo.ClientStatusView b ON a.CL_ID = b.CL_ID INNER JOIN
			dbo.CourierTable ON COUR_ID = ACT_ID_COUR INNER JOIN
			@cour ON CR_ID = COUR_ID
		WHERE (ACT_DATE <= @actdate OR ACT_DATE IS NULL)
			AND (ACT_ID_PERIOD = @actperiod OR ACT_ID_PERIOD IS NULL)
			AND DSS_ACT = 1
		ORDER BY COUR_NAME, CL_PSEDO, CL_ID, ACT_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_SIGN_REPORT] TO rl_act_r;
GO
