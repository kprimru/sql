USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [KGS].[MEMO_CLAIM_PRINT]
	@ID	UNIQUEIDENTIFIER
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
			CL_NAME AS CLIENT, b.FULL_NAME AS VENDOR, c.TS_URL AS TRADESITE, 
			CONVERT(VARCHAR(20), DATE_LIMIT, 104) + ' ' + CONVERT(VARCHAR(20), DATE_LIMIT, 108) AS DATE_LIMIT,
			CLAIM_SUM, ISNULL(CONVERT(VARCHAR(20), TENDER_DATE, 104) + ' ', '') + TENDER_NUM AS TENDER_DATA,
			DETAILS, CASE RTRN WHEN 0 THEN 'Нет' WHEN 1 THEN 'Да' ELSE '???' END AS RTRN,
			RTRN_RULE,
			ISNULL(CONVERT(VARCHAR(20), CO_BEGIN, 104) + ' - ' + CONVERT(VARCHAR(20), CO_END, 104) + ', ', '') + 
				ISNULL(CONVERT(VARCHAR(20), CO_DISCOUNT), '') + ', ' + ISNULL(CONVERT(VARCHAR(20), CO_SUM), '') AS CONTRACT_DATA
		FROM 
			KGS.MemoClaim a
			INNER JOIN dbo.Vendor b ON a.ID_VENDOR = b.ID
			INNER JOIN Purchase.Tradesite c ON a.ID_TRADESITE = c.TS_ID
		WHERE a.ID = @ID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
