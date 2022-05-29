USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[SUBHOST_DBF_DELIVERY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[SUBHOST_DBF_DELIVERY]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[SUBHOST_DBF_DELIVERY]
	@PARAM	NVARCHAR(MAX) = NULL
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

		IF OBJECT_ID('tempdb..#regnode') IS NOT NULL
			DROP TABLE #regnode

		CREATE TABLE #regnode
			(
				REG_ID BIGINT PRIMARY KEY,
				REG_ID_PERIOD SMALLINT,
				REG_ID_SYSTEM SMALLINT,
				REG_DISTR_NUM INT,
				REG_COMP_NUM TINYINT,
				REG_ID_TYPE SMALLINT,
				REG_ID_NET SMALLINT,
				REG_ID_OLD_SYS SMALLINT,
				REG_ID_NEW_SYS SMALLINT,
				REG_ID_OLD_NET SMALLINT,
				REG_ID_NEW_NET SMALLINT,
				SH_LST_NAME NVARCHAR(20),
				PR_DATE DATETIME,
				RNS_COMMENT NVARCHAR(100)
			)

		INSERT INTO #regnode
			SELECT
				RNS_ID, RNS_ID_PERIOD, RNS_ID_SYSTEM, RNS_DISTR,
				RNS_COMP, RNS_ID_TYPE, RNS_ID_NET,
				RNS_ID_OLD_SYS, RNS_ID_NEW_SYS,
				RNS_ID_OLD_NET, RNS_ID_NEW_NET,
				SH_LST_NAME, PR_DATE, RNS_COMMENT
			FROM [DBF].[Subhost.RegNodeSubhostTable]
			INNER JOIN [DBF].[dbo.SubhostTable] ON RNS_ID_HOST = SH_ID
			INNER JOIN [DBF].[dbo.PeriodTable] ON RNS_ID_PERIOD = PR_ID
			WHERE SH_LST_NAME IN ('М', 'У1', 'Л1', 'Н1')
				AND PR_DATE >= DATEADD(YEAR, -1, GETDATE())
				AND PR_DATE <= GETDATE()


				SELECT
					SH_LST_NAME AS [Подхост], PR_DATE AS [Месяц],
					RNS_COMMENT AS [Примечание],
					CASE
						WHEN REG_ID_OLD_SYS IS NULL AND REG_ID_NEW_SYS IS NULL THEN b.SYS_SHORT_NAME
						ELSE 'с ' + e.SYS_SHORT_NAME + ' на '  + f.SYS_SHORT_NAME
					END AS [Система],
					CASE
						WHEN REG_ID_OLD_NET IS NULL AND REG_ID_NEW_NET IS NULL THEN c.SN_NAME
						ELSE
							'с ' + ISNULL(g.SN_NAME, '') + ' на ' + ISNULL(h.SN_NAME, '')
					END [Сеть],
					dbo.DistrString(NULL, REG_DISTR_NUM, REG_COMP_NUM) AS [Дистрибутив],
					CASE SST_LST WHEN '' THEN 'КОМ' ELSE SST_LST END AS [Тип системы]
				FROM #regnode a
				INNER JOIN [DBF].[dbo.SystemTypeTable] ON SST_ID = REG_ID_TYPE
				INNER JOIN [DBF].[dbo.SystemTable] b ON b.SYS_ID = a.REG_ID_SYSTEM
				INNER JOIN [DBF].[dbo.SystemNetTable] c ON SN_ID = a.REG_ID_NET
				LEFT JOIN [DBF].[dbo.SystemTable] e ON e.SYS_ID = a.REG_ID_OLD_SYS
				LEFT JOIN [DBF].[dbo.SystemTable] f ON f.SYS_ID = a.REG_ID_NEW_SYS
				LEFT JOIN [DBF].[dbo.SystemNetTable] g ON g.SN_ID = a.REG_ID_OLD_NET
				LEFT JOIN [DBF].[dbo.SystemNetTable] h ON h.SN_ID = a.REG_ID_NEW_NET
		ORDER BY PR_DATE DESC, SH_LST_NAME, RNS_COMMENT


		IF OBJECT_ID('tempdb..#regnode') IS NOT NULL
			DROP TABLE #regnode

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[SUBHOST_DBF_DELIVERY] TO rl_report;
GO
