USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[NDS_PURCHASE_PROCESS]
	@ORG	SMALLINT,
	@TAX	SMALLINT,
	@PERIOD	SMALLINT
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

		DECLARE @PR_BEGIN	SMALLDATETIME
		DECLARE @PR_END		SMALLDATETIME

		SELECT @PR_BEGIN = PR_DATE, @PR_END = PR_END_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PERIOD

		DECLARE @TP INT

		DECLARE INVOICE CURSOR LOCAL FOR
			SELECT INS_ID
			FROM dbo.InvoiceSaleTable
			WHERE INS_DATE BETWEEN @PR_BEGIN AND @PR_END
				AND INS_ID_ORG = @ORG
				AND INS_ID_TYPE IN
					(
						SELECT INT_ID
						FROM dbo.InvoiceTypeTable
						WHERE INT_PSEDO IN ('ACT', 'CONSIGNMENT')
					)

		OPEN INVOICE

		DECLARE @INS INT

		FETCH NEXT FROM INVOICE INTO @INS

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC dbo.BOOK_PURCHASE_PROCESS @INS

			FETCH NEXT FROM INVOICE INTO @INS
		END

		CLOSE INVOICE
		DEALLOCATE INVOICE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
