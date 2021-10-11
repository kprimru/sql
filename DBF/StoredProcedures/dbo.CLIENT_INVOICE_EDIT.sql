USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_INVOICE_EDIT]
	@invid INT,
	@INS_ID_ORG SMALLINT,
	@INS_DATE smalldatetime,
	@INS_NUM INT,
	@INS_NUM_YEAR varchar(5),
	@INS_ID_CLIENT int,
--	@INS_CLIENT_PSEDO varchar(100),
	@INS_CLIENT_NAME varchar(500),
	@INS_CLIENT_ADDR varchar(500),
	@INS_CONSIG_NAME varchar(500),
	@INS_CONSIG_ADDR varchar(500),
	@INS_CLIENT_INN varchar(50),
	@INS_CLIENT_KPP varchar(50),
--	@INS_INCOME_DATE smalldatetime,
	@INS_DOC_STRING varchar(200),
	@INS_STORNO bit,
	@INS_COMMENT varchar(200),
	@INS_TYPE SMALLINT,
	@INS_IDENT NVARCHAR(128)

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

		INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
			SELECT INS_ID_CLIENT, INS_ID, 'INVOICE', 'Изменение даты с/ф', 'с ' + CONVERT(VARCHAR(20), INS_DATE, 104) + ' на ' + CONVERT(VARCHAR(20), @INS_DATE, 104)
			FROM
				dbo.InvoiceSaleTable
			WHERE INS_ID = @Invid
				AND INS_DATE <> @INS_DATE

		INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
			SELECT INS_ID_CLIENT, INS_ID, 'INVOICE', 'Изменение № с/ф', 'с ' + CONVERT(VARCHAR(20), INS_NUM) + ' на ' + CONVERT(VARCHAR(20), @INS_NUM)
			FROM
				dbo.InvoiceSaleTable
			WHERE INS_ID = @Invid
				AND INS_NUM <> @INS_NUM

		UPDATE dbo.InvoiceSaleTable SET
			INS_ID_ORG=@INS_ID_ORG,
			INS_DATE=@INS_DATE,
			INS_NUM=@INS_NUM,
			INS_NUM_YEAR=@INS_NUM_YEAR,
			INS_ID_CLIENT=@INS_ID_CLIENT,
	--		INS_CLIENT_PSEDO=@INS_CLIENT_PSEDO,
			INS_CLIENT_NAME=@INS_CLIENT_NAME,
			INS_CLIENT_ADDR=@INS_CLIENT_ADDR,
			INS_CONSIG_NAME=@INS_CONSIG_NAME,
			INS_CONSIG_ADDR=@INS_CONSIG_ADDR,
			INS_CLIENT_INN=@INS_CLIENT_INN,
			INS_CLIENT_KPP=@INS_CLIENT_KPP,
	--		INS_INCOME_DATE=@INS_INCOME_DATE,
			INS_DOC_STRING=@INS_DOC_STRING,
			INS_STORNO=@INS_STORNO,
			INS_COMMENT=@INS_COMMENT,
			INS_ID_TYPE = @INS_TYPE,
			INS_IDENT = @INS_IDENT
		WHERE INS_ID = @invid

		EXEC dbo.BOOK_SALE_PROCESS @invid
		EXEC dbo.BOOK_PURCHASE_PROCESS @invid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_INVOICE_EDIT] TO rl_invoice_w;
GO
