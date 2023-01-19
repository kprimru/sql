USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_FACT_ACT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_FACT_ACT_SELECT]  AS SELECT 1')
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_FACT_ACT_SELECT]
	@clientid INT
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
		-- 23.06.2009
		SELECT
			AFM_DATE,
			ACT_DATE = IsNull(ACT_DATE, AFM_DATE),
			PR_MONTH AS PR_NAME,
			ORG_SHORT_NAME,
			CL_PSEDO, CL_FULL_NAME,
			(SELECT SUM(AD_TOTAL_PRICE) FROM dbo.ActFactDetailTable WHERE AFD_ID_AFM = AFM_ID) AS AFM_TOTAL_PRICE
		FROM dbo.ActFactMasterTable M
		LEFT JOIN dbo.ActTable A ON A.ACT_ID = M.ACT_ID
		WHERE CL_ID = @clientid
		ORDER BY AFM_DATE DESC
		--GROUP BY AF_DATE, PR_DATE


		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_FACT_ACT_SELECT] TO rl_act_p;
GO
