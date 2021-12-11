USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STATISTIC_SEARCH]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STATISTIC_SEARCH]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[STATISTIC_SEARCH]
	@SYS	INT,
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@DOC	INT
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

		IF @BEGIN IS NULL
			SELECT @BEGIN = MIN(StatisticDate)
			FROM dbo.StatisticTable

		IF @END IS NULL
			SELECT @END = MAX(StatisticDate)
			FROM dbo.StatisticTable

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res


		CREATE TABLE #res
			(
				STAT_ID	INT,
				SYS		INT,
				IB		INT,
				DATE	SMALLDATETIME,
				DOC		INT
			)

		INSERT INTO #res(STAT_ID, SYS, IB, DATE, DOC)
			SELECT StatisticID, SystemID, a.InfoBankID, StatisticDate, Docs
			FROM
				dbo.StatisticTable a
				INNER JOIN	dbo.InfoBankTable b ON a.InfoBankID = b.InfoBankID
				INNER JOIN	dbo.SystemBankTable c ON c.InfoBankID = b.InfoBankID
			WHERE (SystemID = @SYS OR @SYS IS NULL)
				AND StatisticDate BETWEEN @BEGIN AND @END
				AND (Docs = @DOC OR @DOC IS NULL)

		DECLARE @SQL VARCHAR(MAX)

		SET @SQL = 'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #res (STAT_ID)'
		EXEC (@SQL)
		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #res (SYS)'
		EXEC (@SQL)
		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #res (IB) INCLUDE(SYS)'
		EXEC (@SQL)

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		CREATE TABLE #result
			(
				ID			BIGINT	PRIMARY KEY IDENTITY(1, 1),
				MASTER_ID	BIGINT,
				SYS_ID		INT,
				SYS_SHORT	VARCHAR(50),
				IB_ID		INT,
				DOCS		INT,
				DATE		SMALLDATETIME
			)

		INSERT INTO #result(MASTER_ID, SYS_ID, SYS_SHORT, DOCS, DATE)
			SELECT 	DISTINCT
				NULL,
				SYS,
				SystemShortName,
				NULL AS Docs,
				NULL AS DATE
			FROM
				#res a
				INNER JOIN
					(
						SELECT SystemID, CONVERT(BIGINT, SystemOrder) AS SystemOrder, SystemShortName
						FROM dbo.SystemTable
					) AS o_O ON SystemID = SYS

		INSERT INTO #result(MASTER_ID, SYS_SHORT, SYS_ID, IB_ID, DOCS, DATE)
			SELECT DISTINCT
				(
					SELECT ID
					FROM
						#result
					WHERE SYS = SYS_ID AND MASTER_ID IS NULL
				) AS MASTER_ID,
				InfoBankShortName,
				SYS,
				InfoBankID,
				NULL,
				NULL
			FROM
				#res
				INNER JOIN
					(
						SELECT InfoBankShortName, InfoBankID, CONVERT(BIGINT, InfoBankOrder) AS InfoBankOrder
						FROM dbo.InfoBankTable
					) AS i ON IB = InfoBankID
				INNER JOIN
					(
						SELECT SystemID, CONVERT(BIGINT, SystemOrder) AS SystemOrder
						FROM dbo.SystemTable
					) s ON SYS = SystemID

		INSERT INTO #result(MASTER_ID, SYS_SHORT, DOCS, DATE, SYS_ID, IB_ID)
			SELECT
				(
					SELECT ID
					FROM #result
					WHERE SYS = SYS_ID AND IB_ID = IB
				) AS MASTER_ID,
				CONVERT(VARCHAR(20), DATE, 104),
				DOC,
				DATE,
				SYS, IB
			FROM
				#res
				INNER JOIN
					(
						SELECT InfoBankShortName, InfoBankID, CONVERT(BIGINT, InfoBankOrder) AS InfoBankOrder
						FROM dbo.InfoBankTable
					) AS i ON IB = InfoBankID
				INNER JOIN
					(
						SELECT SystemID, CONVERT(BIGINT, SystemOrder) AS SystemOrder
						FROM dbo.SystemTable
					) s ON SYS = SystemID



		SELECT
			ID, MASTER_ID, SYS_SHORT AS SystemShortName, DOCS AS Docs, DATE,
			a.DOCS - (
				SELECT TOP 1 z.DOCS
				FROM #result z
				WHERE z.SYS_ID = a.SYS_ID
					AND z.IB_ID = a.IB_ID
					AND z.DATE < a.DATE
				ORDER BY DATE DESC
			) AS NEW_DOC
		FROM
			#result a
			LEFT OUTER JOIN dbo.SystemTable b ON a.SYS_ID = b.SystemID
			LEFT OUTER JOIN dbo.InfoBankTable c ON a.IB_ID = c.InfoBankID
		ORDER BY SystemOrder, InfoBankOrder, DATE DESC

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STATISTIC_SEARCH] TO public;
GO
