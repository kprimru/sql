USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PRICE_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PRICE_GET]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[PRICE_GET]
	@priceid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT PP_ID, PP_NAME, PT_NAME, PT_ID, PP_COEF_MUL, PP_COEF_ADD, PP_ACTIVE
		FROM
			dbo.PriceTable a INNER JOIN
			dbo.PriceTypeTable b ON a.PP_ID_TYPE = b.PT_ID
		WHERE PP_ID = @priceid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PRICE_GET] TO rl_price_r;
GO
