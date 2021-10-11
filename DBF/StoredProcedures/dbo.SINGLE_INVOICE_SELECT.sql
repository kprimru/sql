USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  24.03.2009
Описание:		все счета-фактуры клиента
*/

ALTER PROCEDURE [dbo].[SINGLE_INVOICE_SELECT]
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

		SELECT	INS_ID,
				INS_DATE, (CONVERT(varchar,INS_NUM)+'/'+INS_NUM_YEAR) AS INS_FULL_NUM,
				ORG_PSEDO,
				IF_TOTAL_PRICE, -- INS_STORNO, INS_COMMENT,
				INT_NAME
		FROM dbo.InvoiceView
		WHERE INS_ID_CLIENT IS NULL
		ORDER BY INS_DATE DESC, INS_NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
