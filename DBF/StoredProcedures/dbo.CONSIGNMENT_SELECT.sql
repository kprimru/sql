USE [DBF]
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
CREATE PROCEDURE [dbo].[CONSIGNMENT_SELECT]
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
			CSG_ID, CSG_DATE, CSG_NUM, 
			ISNULL((
				SELECT SUM(CSD_TOTAL_PRICE)
				FROM dbo.ConsignmentDetailTable
				WHERE CSD_ID_CONS = CSG_ID
			), 0) AS CSG_SUM, 
			(CONVERT(VARCHAR, INS_NUM) + '/' + INS_NUM_YEAR) AS INS_NUM,
			CSG_PRINT, CSG_SIGN, ORG_PSEDO
		FROM 
			dbo.ConsignmentTable INNER JOIN 
			dbo.OrganizationTable ON ORG_ID = CSG_ID_ORG LEFT OUTER JOIN
			dbo.InvoiceSaleTable ON INS_ID = CSG_ID_INVOICE
		WHERE CSG_ID_CLIENT = @clientid
		ORDER BY CSG_DATE DESC, CSG_NUM DESC
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
