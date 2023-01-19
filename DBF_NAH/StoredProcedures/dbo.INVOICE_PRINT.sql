USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INVOICE_PRINT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INVOICE_PRINT]  AS SELECT 1')
GO
/*
Автор:
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[INVOICE_PRINT]
	@numlist VARCHAR(MAX),
	@invyear VARCHAR(5),
	@begindate SMALLDATETIME,
	@enddate SMALLDATETIME,
	@cour VARCHAR(MAX),
	@preview BIT = 1,
	@address BIT = NULL,
	@org SMALLINT = NULL
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

		DECLARE @idlist VARCHAR(MAX)

		SET @idlist = ''
		-- если есть список номеров - то все остальное и не трогаем

		IF @numlist IS NOT NULL
		BEGIN
			IF OBJECT_ID('tempdb..#invnum') IS NOT NULL
				DROP TABLE #invnum

			CREATE TABLE #invnum
				(
					INV_NUM INT
				)

			INSERT INTO #invnum
				SELECT * FROM dbo.GET_TABLE_FROM_LIST(@numlist, ',')


			SELECT @idlist = @idlist + CONVERT(VARCHAR, INS_ID) + ','
			FROM
				dbo.InvoiceSaleTable INNER JOIN
				#invnum ON INV_NUM = INS_NUM
			WHERE INS_NUM_YEAR = @invyear AND INS_ID_ORG = @org

			IF ISNULL(@idlist, '') <> ''
				SET @idlist = LEFT(@idlist, LEN(@idlist) - 1)

			--EXEC dbo.INVOICE_PRINT_BY_ID_LIST @idlist, @preview
			--SELECT @idlist
		END

		-- список сервис-инженеров тожу тут
		IF (@begindate IS NOT NULL) AND (@enddate IS NOT NULL)
		BEGIN
			IF OBJECT_ID('tempdb.#cour') IS NOT NULL
				DROP TABLE #cour

			CREATE TABLE #cour
				(
					COUR_ID INT
				)

			IF @cour IS NULL
				INSERT INTO #cour
					SELECT COUR_ID
					FROM dbo.CourierTable
			ELSE
				INSERT INTO #cour
					SELECT * FROM dbo.GET_TABLE_FROM_LIST(@cour, ',')

			SELECT @idlist = @idlist + CONVERT(VARCHAR, INS_ID) + ','
			FROM
				dbo.InvoiceSaleTable INNER JOIN
				#cour ON COUR_ID =
				(SELECT TOP 1 TO_ID_COUR FROM dbo.TOTable WHERE TO_ID_CLIENT = INS_ID_CLIENT ORDER BY TO_ID_COUR)
			WHERE INS_DATE BETWEEN @begindate AND @enddate AND INS_ID_ORG = @org

			IF ISNULL(@idlist, '') <> ''
				SET @idlist = LEFT(@idlist, LEN(@idlist) - 1)

			--SELECT @idlist

			--SELECT @idlist
		END

		IF @address = 1
		BEGIN
			DECLARE INS CURSOR LOCAL FOR
				SELECT INS_ID
				FROM
					dbo.InvoiceSaleTable INNER JOIN
					dbo.GET_TABLE_FROM_LIST(@idlist, ',') ON Item = INS_ID

			OPEN INS

			DECLARE @insid INT

			FETCH NEXT FROM INS INTO @insid

			WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC dbo.INVOICE_RECALC_ADDRESS @insid

				FETCH NEXT FROM INS INTO @insid
			END

			CLOSE INS
			DEALLOCATE INS
		END

		EXEC dbo.INVOICE_PRINT_BY_ID_LIST @idlist, @preview


		IF OBJECT_ID('tempdb..#invnum') IS NOT NULL
			DROP TABLE #invnum
		IF OBJECT_ID('tempdb.#cour') IS NOT NULL
			DROP TABLE #cour

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[INVOICE_PRINT] TO rl_invoice_p;
GO
