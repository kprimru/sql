USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:		
*/

ALTER PROCEDURE [dbo].[CLIENT_FACT_CONSIGNMENT_SELECT]
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

		SELECT CFM_DATE, 
			(
				SELECT SUM(CSD_TOTAL_PRICE)
				FROM dbo.ConsignmentFactDetailTable
				WHERE CFD_ID_CFM = CFM_ID
			) AS CSD_TOTAL_PRICE, 
			CFM_NUM
		FROM dbo.ConsignmentFactMasterTable
		WHERE CL_ID = @clientid
		ORDER BY CFM_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_FACT_CONSIGNMENT_SELECT] TO rl_consignment_p;
GO