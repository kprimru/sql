USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PRICE_TYPE_DEPEND_GET]
	@PT_ID		SMALLINT
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

		DECLARE @PR_ID	SMALLINT
		DECLARE @PR_NAME	VARCHAR(50)

		SELECT @PR_ID = PR_ID, @PR_NAME = PR_NAME
		FROM dbo.PeriodTable
		WHERE GETDATE() BETWEEN PR_DATE AND PR_END_DATE

		SELECT
			a.PT_ID, a.PT_NAME, @PR_ID AS PR_ID, @PR_NAME AS PR_NAME,
			c.PT_ID AS PT_ID_DEPEND, c.PT_NAME AS PT_NAME_DEPEND, ISNULL(PD_COEF, 1) AS PD_COEF
		FROM
			dbo.PriceTypeTable a
			LEFT OUTER JOIN dbo.PriceDepend b ON a.PT_ID = b.PD_ID_TYPE AND PD_ID_PERIOD = @PR_ID
			LEFT OUTER JOIN dbo.PriceTypeTable c ON c.PT_ID = b.PD_ID_SOURCE
		WHERE a.PT_ID = @PT_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PRICE_TYPE_DEPEND_GET] TO rl_price_type_r;
GO