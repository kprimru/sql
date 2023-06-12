USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_BILL_FACT_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_BILL_FACT_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_BILL_FACT_GET]
	@clientid INT,
	@date VARCHAR(100)
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

		DECLARE @d DATETIME
		SET @d = CONVERT(DATETIME, @date, 121)

		SELECT *
		FROM dbo.BillFactMasterTable
		WHERE BFM_DATE = @d AND CL_ID = @clientid

		SELECT BillFactDetailTable.*
		FROM
			dbo.BillFactDetailTable INNER JOIN
			dbo.BillFactMasterTable ON BFD_ID_BFM = BFM_ID
		WHERE BFM_DATE = @d

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_BILL_FACT_GET] TO rl_bill_p;
GO
