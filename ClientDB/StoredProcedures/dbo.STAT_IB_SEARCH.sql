USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STAT_IB_SEARCH]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@MODE	TINYINT
	/*
	+1 - системы - даты
	+2 - системы - иб - даты
	*/
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#result') IS NOT NULL
		DROP TABLE #result
		
	CREATE TABLE #result
		(
			ID			UNIQUEIDENTIFIER PRIMARY KEY,
			ID_MASTER	UNIQUEIDENTIFIER,
			SYS_ID		INT,
			IB_ID		INT,
			DATE		SMALLDATETIME,
			NAME		NVARCHAR(128),
			DOCS		INT,
			DELTA		INT,
			ORD			INT,
			LVL			TINYINT
		)
	/*
	DECLARE @SQL VARCHAR(MAX)
	
	SET @SQL = 'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #result (ID)'
	EXEC (@SQL)
	SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #result (SYS_ID)'
	EXEC (@SQL)
	SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #result (IB_ID) INCLUDE(SYS_ID)'
	EXEC (@SQL)	
	SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #result (LVL) INCLUDE(ID, SYS_ID, IB_ID)'
	EXEC (@SQL)	
	*/

	IF @MODE = 1
	BEGIN
		INSERT INTO #result(ID, SYS_ID, NAME, ORD, LVL)
			SELECT NEWID(), SystemID, SystemShortName, SystemOrder, 1
			FROM dbo.SystemTable
			WHERE SystemActive = 1
			
		INSERT INTO #result(ID, ID_MASTER, SYS_ID, NAME, DATE, DOCS, ORD, LVL)
			SELECT NEWID(), (SELECT ID FROM #result WHERE LVL = 1 AND SYS_ID = SystemID), SystemID, CONVERT(VARCHAR(20), StatisticDate, 104), StatisticDate, 
				(
					SELECT SUM(Docs)
					FROM 
						(
							SELECT SystemID, a.InfoBankID, MAX(b.StatisticDate) AS StatisticDate
							FROM 
								dbo.SystemBanksView a WITH(NOEXPAND)
								INNER JOIN dbo.StatisticTable b ON a.InfoBankID = b.InfoBankID
							WHERE b.StatisticDate <= t.StatisticDate AND t.SystemID = a.SystemID AND SystemActive = 1 AND InfoBankActive = 1
							GROUP BY SystemID, a.InfoBankID
						) AS p
						INNER JOIN dbo.StatisticTable q ON q.InfoBankID = p.InfoBankID AND q.StatisticDate = p.StatisticDate
				), SystemOrder, 2
			FROM
				(
					SELECT DISTINCT SystemID, SystemOrder, StatisticDate
					FROM 
						dbo.SystemBanksView a WITH(NOEXPAND)
						INNER JOIN dbo.StatisticTable b ON a.InfoBankID = b.InfoBankID
					WHERE (StatisticDate >= @BEGIN  OR @BEGIN IS NULL)
						AND (StatisticDate <= @END OR @END IS NULL)
						AND SystemActive = 1 AND InfoBankActive = 1
				) AS t			
						
		UPDATE a
		SET DELTA = DOCS - 
			(
				SELECT TOP 1 DOCS
				FROM #result b
				WHERE LVL = 2
					AND a.SYS_ID = b.SYS_ID
					AND b.DATE < a.DATE
				ORDER BY DATE DESC
			)
		FROM #result a
		WHERE LVL = 2
		
		UPDATE a
		SET DOCS = 
			(
				SELECT TOP 1 DOCS
				FROM #result b
				WHERE b.LVL = 2
					AND b.SYS_ID = a.SYS_ID
				ORDER BY DATE DESC
			)
		FROM #result a
		WHERE LVL = 1	
	END
		
	IF @MODE = 2
	BEGIN
		INSERT INTO #result(ID, SYS_ID, NAME, ORD, LVL)
			SELECT NEWID(), SystemID, SystemShortName, SystemOrder, 1
			FROM dbo.SystemTable
			WHERE SystemActive = 1
			
		INSERT INTO #result(ID, ID_MASTER, SYS_ID, IB_ID, NAME, ORD, LVL)
			SELECT NEWID(), (SELECT ID FROM #result WHERE LVL = 1 AND SYS_ID = SystemID), SystemID, InfoBankID, InfoBankShortName, InfoBankOrder, 2
			FROM dbo.SystemBanksView WITH(NOEXPAND)
			WHERE SystemActive = 1 AND InfoBankActive = 1
			
		INSERT INTO #result(ID, ID_MASTER, SYS_ID, IB_ID, NAME, DATE, DOCS, LVL)
			SELECT NEWID(), (SELECT ID FROM #result WHERE SYS_ID = SystemID AND IB_ID = a.InfoBankID AND LVL = 2), SystemID, a.InfoBankID, CONVERT(VARCHAR(20), StatisticDate, 104), StatisticDate, Docs, 3
			FROM 
				dbo.SystemBanksView a WITH(NOEXPAND)
				INNER JOIN dbo.StatisticTable b ON a.InfoBankID = b.InfoBankID
			WHERE (StatisticDate >= @BEGIN  OR @BEGIN IS NULL)
				AND (StatisticDate <= @END OR @END IS NULL)
				AND SystemActive = 1 AND InfoBankActive = 1
				
		UPDATE a
		SET DELTA = DOCS - 
			(
				SELECT TOP 1 DOCS
				FROM #result b
				WHERE LVL = 3
					AND a.SYS_ID = b.SYS_ID
					AND a.IB_ID = b.IB_ID
					AND b.DATE < a.DATE
				ORDER BY DATE DESC
			)
		FROM #result a
		WHERE LVL = 3
		
		UPDATE a
		SET DOCS = 
			(
				SELECT TOP 1 DOCS
				FROM #result b
				WHERE b.LVL = 3
					AND b.IB_ID = a.IB_ID
					AND b.SYS_ID = a.SYS_ID
				ORDER BY DATE DESC
			)
		FROM #result a
		WHERE LVL = 2
		
		UPDATE a
		SET DOCS = 
			(
				SELECT SUM(DOCS)
				FROM #result b
				WHERE b.LVL = 2
					AND b.SYS_ID = a.SYS_ID
			)
		FROM #result a
		WHERE LVL = 1
	END
	
	IF @MODE = 3
	BEGIN
		INSERT INTO #result(ID, DATE, NAME, DOCS, LVL)
			SELECT 
				NEWID(), StatisticDate, CONVERT(VARCHAR(20), StatisticDate, 104), 
				(
					SELECT SUM(Docs)
					FROM 
						(
							SELECT SystemID, a.InfoBankID, MAX(b.StatisticDate) AS StatisticDate
							FROM 
								dbo.SystemBanksView a WITH(NOEXPAND)
								INNER JOIN dbo.StatisticTable b ON a.InfoBankID = b.InfoBankID
							WHERE b.StatisticDate <= t.StatisticDate AND SystemActive = 1 AND InfoBankActive = 1
							GROUP BY SystemID, a.InfoBankID
						) AS p
						INNER JOIN dbo.StatisticTable q ON q.InfoBankID = p.InfoBankID AND q.StatisticDate = p.StatisticDate
				),
				1
			FROM
				(
					SELECT DISTINCT StatisticDate
					FROM dbo.StatisticTable
					WHERE (StatisticDate >= @BEGIN  OR @BEGIN IS NULL)
						AND (StatisticDate <= @END OR @END IS NULL)
				) AS t			
					
		INSERT INTO #result(ID, ID_MASTER, SYS_ID, NAME, DATE, ORD, LVL)
			SELECT 
				NEWID(), (SELECT ID FROM #result WHERE DATE = StatisticDate AND LVL = 1), 
				SystemID, SystemShortName, StatisticDate, SystemOrder, 2
			FROM 
				(
					SELECT DISTINCT SystemID, SystemShortName, SystemOrder, StatisticDate
					FROM
						dbo.SystemBanksView a WITH(NOEXPAND)
						INNER JOIN dbo.StatisticTable b ON a.InfoBankID = b.InfoBankID
					WHERE (StatisticDate >= @BEGIN  OR @BEGIN IS NULL)
						AND (StatisticDate <= @END OR @END IS NULL)
						AND SystemActive = 1 AND InfoBankActive = 1
				) AS o_O
				
		INSERT INTO #result(ID, ID_MASTER, SYS_ID, IB_ID, NAME, DOCS, ORD, LVL)
			SELECT 
				NEWID(), (SELECT ID FROM #result WHERE DATE = StatisticDate AND SYS_ID = SystemID AND LVL = 2), 
				SystemID, InfoBankID, InfoBankShortName, Docs, InfoBankOrder, 3
			FROM 
				(
					SELECT DISTINCT SystemID, a.InfoBankID, InfoBankShortName, InfoBankOrder, StatisticDate, Docs
					FROM
						dbo.SystemBanksView a WITH(NOEXPAND)
						INNER JOIN dbo.StatisticTable b ON a.InfoBankID = b.InfoBankID
					WHERE (StatisticDate >= @BEGIN  OR @BEGIN IS NULL)
						AND (StatisticDate <= @END OR @END IS NULL)
						AND SystemActive = 1 AND InfoBankActive = 1
				) AS o_O
				
		UPDATE a
		SET DELTA = DOCS - 
			(
				SELECT TOP 1 DOCS
				FROM #result b
				WHERE LVL = 1
					AND b.DATE < a.DATE
				ORDER BY DATE DESC
			)
		FROM #result a
		WHERE LVL = 1	
		
		UPDATE a
		SET DOCS = 
			(
				SELECT SUM(DOCS)
				FROM #result b
				WHERE b.LVL = 3
					AND b.SYS_ID = a.SYS_ID
			)
		FROM #result a
		WHERE LVL = 2	
	END
		
	DELETE a
	FROM #result a
	WHERE LVL <> (SELECT MAX(LVL) FROM #result)
		AND NOT EXISTS
			(
				SELECT *
				FROM #result b
				WHERE a.ID = b.ID_MASTER
			)
		
	SELECT *
	FROM #result
	ORDER BY LVL, ORD, DATE DESC
		
	IF OBJECT_ID('tempdb..#result') IS NOT NULL
		DROP TABLE #result
END
