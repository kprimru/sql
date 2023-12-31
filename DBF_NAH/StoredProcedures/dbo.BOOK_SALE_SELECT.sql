USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[BOOK_SALE_SELECT]
	@INVOICE	INT,
	@ORG		SMALLINT,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@ERROR		BIT,
	@NAME		VARCHAR(100)
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

		IF @INVOICE IS NOT NULL
		BEGIN
			SET @BEGIN = NULL
			SET @END = NULL
			SET @ORG = NULL
			SET @ERROR = NULL
			SET @NAME = NULL
		END

		SELECT ID, ORG_PSEDO, ID_INVOICE, CODE, NUM, DATE, NAME, INN, KPP, IN_NUM, IN_DATE, S_ALL, ERR
		FROM
			(
				SELECT
					ID, ORG_PSEDO, ID_INVOICE, CODE, NUM, DATE, NAME, INN, KPP, IN_NUM, IN_DATE,
					(
						SELECT SUM(S_ALL)
						FROM dbo.BookSaleDetail z
						WHERE z.ID_SALE = a.ID
					) AS S_ALL,
					CASE
						WHEN ISNULL(INN, '') = '' THEN '�� ��������� ���� ���'
						WHEN LEN(ISNULL(INN, '')) NOT IN (10, 12) THEN '�������� ����� ���� ���'
						WHEN LEN(ISNULL(INN, '')) = 10 AND LEN(ISNULL(KPP, '')) <> 9 THEN '�������� ����� ���� ���'
						ELSE ''
					END AS ERR
				FROM
					dbo.BookSale a
					INNER JOIN dbo.OrganizationTable b ON ORG_ID = ID_ORG
				WHERE (ID_INVOICE = @INVOICE OR @INVOICE IS NULL)
					AND (ID_ORG = @ORG OR @ORG IS NULL)
					AND (DATE >= @BEGIN OR @BEGIN IS NULL)
					AND (DATE <= @END OR @END IS NULL)
					AND (NAME LIKE @NAME OR @NAME IS NULL)
			) AS p
		WHERE (ERR <> '' AND @ERROR = 1 OR @ERROR = 0 OR @ERROR IS NULL)
		ORDER BY DATE DESC, NUM DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[BOOK_SALE_SELECT] TO rl_book_sale_p;
GO
