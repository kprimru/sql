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

ALTER PROCEDURE [dbo].[INVOICE_LIST_SELECT]
	@begindate SMALLDATETIME,
	@enddate SMALLDATETIME,
	@beginnum INT = NULL,
	@endnum INT = NULL
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

		SELECT *
		FROM dbo.InvoiceListView
		WHERE
			(INS_DATE >= @begindate OR @begindate IS NULL) AND
			(INS_DATE <= @enddate OR @enddate IS NULL)  AND
			(INS_NUM >= @beginnum OR @beginnum IS NULL) AND
			(INS_NUM <= @endnum OR @endnum IS NULL)
		ORDER BY INS_DATE, INS_NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INVOICE_LIST_SELECT] TO rl_invoice_r;
GO
