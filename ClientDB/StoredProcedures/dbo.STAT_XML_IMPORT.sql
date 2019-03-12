USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[STAT_XML_IMPORT]
	@DATA	NVARCHAR(MAX),
	@NEW	INT = NULL OUTPUT,
	@UPDATE	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @xml XML
	DECLARE @hdoc INT
	
	IF OBJECT_ID('tempdb..#stat') IS NOT NULL
		DROP TABLE #stat

	CREATE TABLE #stat
		(				
			DT			SMALLDATETIME,
			SYS_NAME	VARCHAR(50),
			IB_NAME		VARCHAR(50),
			DOC			INT
		)
			
	SET @xml = CAST(@DATA AS XML)

	EXEC sp_xml_preparedocument @hdoc OUTPUT, @xml

	INSERT INTO #stat(DT, SYS_NAME, IB_NAME, DOC)
		SELECT 
			CONVERT(SMALLDATETIME, c.value('(@DT)', 'VARCHAR(20)'), 112),
			c.value('(@SYS)', 'VARCHAR(50)'),
			c.value('(@IB)', 'VARCHAR(50)'),
			c.value('(@DOC)', 'INT')
		FROM @xml.nodes('/LIST/ITEM') AS a(c)

	INSERT INTO dbo.StatisticTable(StatisticDate, InfoBankID, Docs)
		SELECT 
			CONVERT(SMALLDATETIME, DT, 112),
			b.InfoBankID, DOC
		FROM 
			#stat a
			INNER JOIN dbo.InfoBankTable b ON InfoBankName = IB_NAME
			INNER JOIN dbo.SystemBankTable c ON c.InfoBankID = b.InfoBankID
			INNER JOIN dbo.SystemTable d ON d.SystemID = c.SystemID AND SYS_NAME = SystemBaseName
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.StatisticTable z
				WHERE z.StatisticDate = a.DT
					AND z.InfoBankID = b.InfoBankID
			)
	SET @NEW = @@ROWCOUNT
	
	UPDATE t
	SET t.Docs = DOC
	FROM
		dbo.StatisticTable t
		INNER JOIN dbo.InfoBankTable a ON a.InfoBankID = t.InfoBankID
		INNER JOIN dbo.SystemBankTable b ON a.InfoBankID = b.InfoBankID
		INNER JOIN dbo.SystemTable c ON c.SystemID = b.SystemID
		INNER JOIN #stat d ON d.IB_NAME = a.InfoBankName 
						AND d.SYS_NAME = c.SystemBaseName 
						AND t.StatisticDate = d.DT
	WHERE t.Docs <> DOC
	
	SET @UPDATE = @@ROWCOUNT
	
	EXEC sp_xml_removedocument @hdoc
END