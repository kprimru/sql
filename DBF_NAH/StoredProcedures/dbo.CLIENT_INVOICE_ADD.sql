USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:	2-04-2009
Описание:		добавить счет-фактуру (только полевые данные, без таблицы)
*/

ALTER PROCEDURE [dbo].[CLIENT_INVOICE_ADD]
	@INS_ID_ORG SMALLINT,
	@INS_DATE SMALLDATETIME,
	@INS_NUM INT,
	@INS_NUM_YEAR VARCHAR(5),
	@INS_ID_CLIENT INT,
--	@INS_CLIENT_PSEDO varchar(100),
	@INS_CLIENT_NAME VARCHAR(500),
	@INS_CLIENT_ADDR VARCHAR(500),
	@INS_CONSIG_NAME VARCHAR(500),
	@INS_CONSIG_ADDR VARCHAR(500),
	@INS_CLIENT_INN VARCHAR(50),
	@INS_CLIENT_KPP VARCHAR(50),
	@INS_DOC_STRING VARCHAR(200),
	@INS_STORNO BIT,
	@INS_COMMENT VARCHAR(200),
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

		DECLARE @ID INT

		DECLARE @payer INT

		SELECT @payer = CL_ID_PAYER
		FROM dbo.ClientTable
		WHERE CL_ID = @INS_ID_CLIENT

		INSERT INTO dbo.InvoiceSaleTable
			(
			INS_ID_ORG,
			INS_DATE,
			INS_NUM,
			INS_NUM_YEAR,
			INS_ID_CLIENT,
	--		INS_CLIENT_PSEDO,
			INS_CLIENT_NAME,
			INS_CLIENT_ADDR,
			INS_CONSIG_NAME,
			INS_CONSIG_ADDR,
			INS_CLIENT_INN,
			INS_CLIENT_KPP,
			INS_DOC_STRING,
			INS_STORNO,
			INS_COMMENT,
			INS_ID_TYPE,
			INS_ID_PAYER,
			INS_IDENT
			)
		VALUES
			(
			@INS_ID_ORG,
			@INS_DATE,
			@INS_NUM,
			@INS_NUM_YEAR,
			@INS_ID_CLIENT,
	--		@INS_CLIENT_PSEDO,
			@INS_CLIENT_NAME,
			@INS_CLIENT_ADDR,
			@INS_CONSIG_NAME,
			@INS_CONSIG_ADDR,
			@INS_CLIENT_INN,
			@INS_CLIENT_KPP,
			@INS_DOC_STRING,
			@INS_STORNO,
			@INS_COMMENT,
			@INS_TYPE,
			@payer,
			@INS_IDENT
			)

		SELECT @ID = SCOPE_IDENTITY()

		SELECT @ID AS NEW_IDEN

		INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
			SELECT INS_ID_CLIENT, INS_ID, 'INVOICE', 'Создание с/ф', '№' + CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR)
			FROM
				dbo.InvoiceSaleTable
			WHERE INS_ID = @ID

		EXEC dbo.BOOK_SALE_PROCESS @ID
		EXEC dbo.BOOK_PURCHASE_PROCESS @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_INVOICE_ADD] TO rl_invoice_w;
GO
