USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[IMPORT_DBF_DATA]
	@DATA		NVARCHAR(MAX),
	@OUT_DATA	NVARCHAR(512) = NULL OUTPUT
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

		DECLARE @XML XML

		SET @XML = CAST(@DATA AS XML)

		DECLARE @REFRESH	INT

		SET @REFRESH = 0

		DELETE FROM dbo.DBFIncome
		DELETE FROM dbo.DBFBill
		DELETE FROM dbo.DBFAct

		INSERT INTO dbo.DBFIncome(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, ID_PRICE)
			SELECT
				c.value('s[1]', 'NVARCHAR(64)'),
				c.value('d[1]', 'INT'),
				c.value('c[1]', 'INT'),
				CONVERT(SMALLDATETIME, c.value('m[1]', 'NVARCHAR(64)'), 112),
				c.value('p[1]', 'MONEY')
			FROM @xml.nodes('/dbf_data/income/i') AS a(c)

		SET @REFRESH = @REFRESH + @@ROWCOUNT

		INSERT INTO dbo.DBFAct(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, AD_TOTAL_PRICE)
			SELECT
				c.value('s[1]', 'NVARCHAR(64)'),
				c.value('d[1]', 'INT'),
				c.value('c[1]', 'INT'),
				CONVERT(SMALLDATETIME, c.value('m[1]', 'NVARCHAR(64)'), 112),
				c.value('p[1]', 'MONEY')
			FROM @xml.nodes('/dbf_data/act/i') AS a(c)

		SET @REFRESH = @REFRESH + @@ROWCOUNT

		INSERT INTO dbo.DBFBill(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, BD_TOTAL_PRICE)
			SELECT
				c.value('s[1]', 'NVARCHAR(64)'),
				c.value('d[1]', 'INT'),
				c.value('c[1]', 'INT'),
				CONVERT(SMALLDATETIME, c.value('m[1]', 'NVARCHAR(64)'), 112),
				c.value('p[1]', 'MONEY')
			FROM @xml.nodes('/dbf_data/bill/i') AS a(c)

		SET @REFRESH = @REFRESH + @@ROWCOUNT

		SET @OUT_DATA = '��������� ' + CONVERT(NVARCHAR(32), @REFRESH) + ' �������'

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[IMPORT_DBF_DATA] TO rl_import_data;
GO
