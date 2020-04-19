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
CREATE PROCEDURE [dbo].[CLIENT_FACT_BILL_SELECT]
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
	
		SELECT 
			BFM_ID,
			BFM_DATE, 
			(
				SELECT SUM(BD_TOTAL_UNPAY)
				FROM dbo.BillFactDetailTable
				WHERE BFD_ID_BFM = BFM_ID
			) AS BD_TOTAL_PRICE, 
			BFM_NUM, BFM_ID_PERIOD, BILL_DATE, ORG_PSEDO
		FROM 
			dbo.BillFactMasterTable a INNER JOIN
			dbo.OrganizationTable b ON a.ORG_ID = b.ORG_ID
		WHERE CL_ID = @clientid
		ORDER BY BFM_DATE DESC
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
