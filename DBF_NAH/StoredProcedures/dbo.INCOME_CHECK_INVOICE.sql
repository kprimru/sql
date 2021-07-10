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

ALTER PROCEDURE [dbo].[INCOME_CHECK_INVOICE]
	@incomeid INT
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

		DECLARE @inv INT

		SELECT @inv = IN_ID_INVOICE
		FROM dbo.IncomeTable
		WHERE IN_ID = @incomeid

		IF @inv IS NULL
			BEGIN
				SELECT 1
				WHERE 1 = 0

				RETURN
			END

		SELECT
			(
				SELECT SUM(IN_SUM)
				FROM dbo.IncomeTable
				WHERE IN_ID_INVOICE = @inv
			) AS IN_SUM,
			(
				SELECT SUM(INR_SALL)
				FROM dbo.InvoiceRowTable
				WHERE INR_ID_INVOICE = @inv
			) AS INS_SUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[INCOME_CHECK_INVOICE] TO rl_income_w;
GO