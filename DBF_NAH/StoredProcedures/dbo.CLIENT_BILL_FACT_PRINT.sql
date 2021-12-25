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

ALTER PROCEDURE [dbo].[CLIENT_BILL_FACT_PRINT]
	@bfmid INT
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

		SELECT *, (SELECT ORG_LOGO FROM dbo.OrganizationTable z WHERE a.ORG_ID = z.ORG_ID) AS ORG_LOGO, 0 AS TO_GROUP
		FROM dbo.BillFactMasterTable a
		WHERE BFM_ID = @bfmid

		SELECT *, NULL AS TO_NUM, NULL AS TO_NAME
		FROM dbo.BillFactDetailTable
		WHERE BFD_ID_BFM = @bfmid
		ORDER BY SYS_ORDER, DIS_ID, PR_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_BILL_FACT_PRINT] TO rl_bill_p;
GO
