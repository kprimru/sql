USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PRICE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PRICE_SELECT]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[PRICE_SELECT]
	@active BIT = NULL
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

		SELECT PP_ID, PP_NAME, PT_NAME, PP_COEF_MUL, PP_COEF_ADD
		FROM
			dbo.PriceTable a INNER JOIN
			dbo.PriceTypeTable b ON a.PP_ID_TYPE = b.PT_ID
		WHERE PP_ACTIVE = ISNULL(@active, PP_ACTIVE)
		ORDER BY PP_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PRICE_SELECT] TO rl_price_r;
GO
