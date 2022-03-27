USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:		  Денисов Алексей
Описание:	  Процедура создания копии рег.узла
*/
ALTER PROCEDURE [dbo].[REG_NODE_LOAD_LOCAL] 
	@filename VARCHAR(MAX)
WITH EXECUTE AS OWNER
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

		--Шаг 1. Выгрузить из РЦ данные с ключом /outcsv
		DECLARE @bcppath VARCHAR(MAX)

		SET @bcppath = dbo.GET_SETTING('BCP_PATH')

		--Шаг 2. Закинуть данные во временную таблицу

		DECLARE @sql NVARCHAR(4000)

		IF OBJECT_ID('tempdb..#reg') IS NOT NULL
			DROP TABLE #reg

		CREATE TABLE #reg
		(
			[RN_SYS_NAME] [varchar](20) NULL,
			[RN_DISTR_NUM] [int] NULL,
			[RN_COMP_NUM] [tinyint] NULL,
			[RN_DISTR_TYPE] [varchar](20) NULL,
			[RN_TECH_TYPE] [varchar](20) NULL,
			[RN_NET_COUNT] [smallint] NULL,
			[RN_SUBHOST] [smallint] NULL,
			[RN_TRANSFER_COUNT] [smallint] NULL,
			[RN_TRANSFER_LEFT] [smallint] NULL,
			[RN_SERVICE] [smallint] NULL,
			--[RN_REG_DATE] [smalldatetime] NULL,
			--[RN_FIRST_REG] [smalldatetime] NULL,
			[RN_REG_DATE] VarChar(100) NULL,
			[RN_FIRST_REG] VarChar(100) NULL,
			[RN_COMMENT] [varchar](255) NULL,
			[RN_COMPLECT] [varchar](50) NULL,
			[RN_REPORT_CODE] [varchar](10) NULL,
			[RN_REPORT_VALUE] [varchar](50) NULL,
			[RN_SHORT] [varchar](10) NULL,
			[RN_MAIN] [tinyint] NULL,
			[RN_SUB] [tinyint] NULL,
			[RN_OFFLINE] [varchar](50) NULL,
			[RN_YUBIKEY] [varchar](50) NULL,
			[RN_KRF] [varchar](50) NULL,
			[RN_KRF1] [varchar](50) NULL,
			REG_PARAM	VARCHAR(50),
			REG_ODON	VARCHAR(50),
			REG_ODOFF	VARCHAR(50),
		)

		--TRUNCATE TABLE dbo.RegNodeTable

		SET @sql = '
		BULK INSERT #reg
		FROM ''' + @filename + '''
		WITH
			(
			FORMATFILE = ''' + @bcppath + ''',
			FIRSTROW = 2
			)'
		--SELECT 1 AS ER_MSG, @sql
		EXEC sp_executesql @sql
		--Шаг 1. Выгрузить из РЦ данные с ключом /outcsv

		UPDATE #reg
		SET RN_COMMENT = CASE WHEN SUBSTRING(RN_COMMENT, 1, 1) = '"' AND SUBSTRING(RN_COMMENT, LEN(RN_COMMENT), 1) = '"' THEN REPLACE(LEFT(RIGHT(RN_COMMENT, LEN(RN_COMMENT) - 1), LEN(RN_COMMENT) - 2), '""', '"') ELSE RN_COMMENT END,
			REG_ODON = CASE WHEN REG_ODON IS NULL THEN 0 ELSE REG_ODON END,
			REG_ODOFF = CASE WHEN REG_ODOFF IS NULL THEN 0 ELSE REG_ODOFF END;

		IF (SELECT COUNT(*) FROM #reg) > 0
		BEGIN
			TRUNCATE TABLE dbo.RegNodeTable

			INSERT INTO dbo.RegNodeTable
			SELECT [RN_SYS_NAME], [RN_DISTR_NUM], [RN_COMP_NUM], [RN_DISTR_TYPE], [RN_TECH_TYPE], [RN_NET_COUNT], [RN_SUBHOST], [RN_TRANSFER_COUNT], [RN_TRANSFER_LEFT], [RN_SERVICE], Convert(SmallDateTime, [RN_REG_DATE], 104), Convert(SmallDateTime, [RN_FIRST_REG], 104), [RN_COMMENT], [RN_COMPLECT], [RN_REPORT_CODE], [RN_REPORT_VALUE], [RN_SHORT], [RN_MAIN], [RN_SUB], [RN_OFFLINE], [RN_YUBIKEY], [RN_KRF], [RN_KRF1], [REG_PARAM], [REG_ODON], [REG_ODOFF]
			FROM #reg

			SELECT @@ROWCOUNT AS ROW_COUNT 

			EXEC [dbo].[DISTR_BUH_CHANGE]
		END

		IF OBJECT_ID('tempdb..#reg') IS NOT NULL
			DROP TABLE #reg

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REG_NODE_LOAD_LOCAL] TO rl_reg_node_w;
GO
