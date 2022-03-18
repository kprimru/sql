USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISTR_DOCUMENT_DEFAULT_SELECT]
	@SaleObject_Id  SmallInt
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
		    Cast(0 AS Bit) AS DD_SELECT,
		    DOC_ID, DOC_NAME,
		    GD_ID, GD_NAME,
		    UN_ID, UN_NAME
	    FROM dbo.DocumentSaleObjectDefaultTable AS DD
	    LEFT JOIN dbo.DocumentTable ON DOC_ID = DSD_ID_DOC
	    LEFT JOIN dbo.GoodTable ON GD_ID = DSD_ID_GOOD
	    LEFT JOIN dbo.UnitTable ON UN_ID = DSD_ID_UNIT
	    WHERE DD.DSD_ID_SO = @SaleObject_Id
	    ORDER BY DOC_ID;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_DOCUMENT_DEFAULT_SELECT] TO rl_distr_financing_w;
GO
