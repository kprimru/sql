USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[IMPORT_ALL_DATA]
	@DATA		NVARCHAR(MAX),
	@OUT_DATA	NVARCHAR(512) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @XML XML
	
	SET @XML = CAST(@DATA AS XML)

	DECLARE @ADD		INT
	DECLARE @REFRESH	INT
	
	SET @ADD = 0
	SET @REFRESH = 0

	INSERT INTO dbo.StatisticTable(StatisticDate, InfoBankID, Docs)
		SELECT DT, y.InfoBankID, IDOCS
		FROM
			(
				SELECT 
					CONVERT(SMALLDATETIME, c.value('(@IDATE)', 'VARCHAR(20)'), 112) AS DT,
					c.value('(@SNAME)', 'VARCHAR(50)') AS SNAME,
					c.value('(@INAME)', 'VARCHAR(50)') AS INAME,
					c.value('(@IDOCS)', 'INT') AS IDOCS
				FROM @xml.nodes('/root/docs/item') AS a(c)
			) AS z
			INNER JOIN dbo.SystemBanksView y WITH(NOEXPAND) ON z.SNAME = y.SystemBaseName AND z.INAME = y.InfoBankName
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.StatisticTable x
				WHERE x.InfoBankID = y.InfoBankID
					AND z.DT = x.StatisticDate
					AND x.Docs = z.IDOCS
			)
		
	SET @ADD = @ADD + @@ROWCOUNT	
			
	DELETE FROM dbo.RegNodeTable
		
	INSERT INTO dbo.RegNodeTable(SystemName, DistrNumber, CompNumber, DistrType, TechnolType, NetCount, SubHost, TransferCount, TransferLeft, Service, RegisterDate, Comment, Complect, ODON, ODOFF)
		SELECT SYS, DISTR, COMP, TYPE, TECH, NET, SUBHOST, TCNT, TLEFT, TSERVICE, TDATE, COMMENT, COMPLECT, ODON, ODOFF
		FROM
			(
				SELECT
					c.value('(@SYS)', 'VARCHAR(50)') AS SYS,
					c.value('(@DISTR)', 'INT') AS DISTR,
					c.value('(@COMP)', 'TINYINT') AS COMP,
					c.value('(@TYPE)', 'VARCHAR(50)') AS TYPE,
					c.value('(@TECH)', 'SMALLINT') AS TECH,
					c.value('(@NET)', 'SMALLINT') AS NET,
					c.value('(@SUBHOST)', 'BIT') AS SUBHOST,
					c.value('(@TCNT)', 'SMALLINT') AS TCNT,
					c.value('(@TLEFT)', 'SMALLINT') AS TLEFT,
					c.value('(@SERVICE)', 'SMALLINT') AS TSERVICE,
					CONVERT(SMALLDATETIME, c.value('(@DATE)', 'VARCHAR(20)'), 104) AS TDATE,
					c.value('(@COMMENT)', 'VARCHAR(100)') AS COMMENT,
					c.value('(@COMPLECT)', 'VARCHAR(50)') AS COMPLECT,
					c.value('(@ODON)', 'VARCHAR(50)') AS ODON,
					c.value('(@ODOFF)', 'VARCHAR(50)') AS ODOFF
				FROM @xml.nodes('/root/reg/item') AS a(c)
			) AS a
			
	SET @REFRESH = @REFRESH + @@ROWCOUNT	
			
	INSERT INTO dbo.RegProtocol(RPR_DATE, RPR_ID_HOST, RPR_DISTR, RPR_COMP, RPR_OPER, RPR_REG, RPR_TYPE, RPR_TEXT, RPR_USER, RPR_COMPUTER)
		SELECT DATE, HostID, DISTR, COMP, OPER, REG, TYPE, TXT, USR, COMPUTER
		FROM
			(
				SELECT 
					c.value('(@HOST)', 'VARCHAR(50)') AS HOST,
					c.value('(@DISTR)', 'INT') AS DISTR,
					c.value('(@COMP)', 'TINYINT') AS COMP,
					CONVERT(SMALLDATETIME, c.value('(@DATE)', 'VARCHAR(50)'), 120) AS DATE,
					c.value('(@REG)', 'TINYINT') AS REG,
					c.value('(@OPER)', 'VARCHAR(50)') AS OPER,
					c.value('(@TYPE)', 'VARCHAR(50)') AS TYPE,
					c.value('(@TEXT)', 'VARCHAR(100)') AS TXT,
					c.value('(@USER)', 'VARCHAR(50)') AS USR,
					c.value('(@COMPUTER)', 'VARCHAR(50)') AS COMPUTER
				FROM @xml.nodes('/root/prot/item') AS a(c)
			) AS z
			INNER JOIN dbo.Hosts ON HostReg = HOST
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.RegProtocol x
				WHERE x.RPR_ID_HOST = HostID
					AND x.RPR_DISTR = DISTR
					AND x.RPR_COMP = COMP
					AND x.RPR_DATE = DATE
					AND x.RPR_TEXT = TXT
					AND x.RPR_OPER = OPER
					AND x.RPR_TYPE = TYPE
			)
				
	SET @ADD = @ADD + @@ROWCOUNT
		
	INSERT INTO Reg.ProtocolText(ID_HOST, DATE, DISTR, COMP, CNT, COMMENT)
		SELECT HostID, DATE, DISTR, COMP, CNT, COMMENT
		FROM
			(
				SELECT 
					c.value('(@HOST)', 'VARCHAR(50)') AS HOST,
					c.value('(@DISTR)', 'INT') AS DISTR,
					c.value('(@COMP)', 'TINYINT') AS COMP,
					CONVERT(SMALLDATETIME, c.value('(@DATE)', 'VARCHAR(20)'), 112) AS DATE,
					c.value('(@CNT)', 'TINYINT') AS CNT,
					c.value('(@COMMENT)', 'VARCHAR(100)') AS COMMENT
				FROM @xml.nodes('/root/prot_text/item') AS a(c)
			) AS z
			INNER JOIN dbo.Hosts ON HostReg = HOST
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Reg.ProtocolText x
				WHERE x.ID_HOST = HostID
					AND x.DISTR = z.DISTR
					AND x.COMP = z.COMP
					AND x.DATE = z.DATE
					AND x.COMMENT = z.COMMENT
			)
				
	SET @ADD = @ADD + @@ROWCOUNT
		
	INSERT INTO Price.SystemPrice(ID_SYSTEM, ID_MONTH, PRICE)
		SELECT DISTINCT SystemID, ID, PRICE
		FROM
			(
				SELECT 
					c.value('(@SYS)', 'VARCHAR(50)') AS SYS,
					c.value('(@PRICE)', 'MONEY') AS PRICE,
					CONVERT(SMALLDATETIME, c.value('(@DATE)', 'VARCHAR(20)'), 112) AS DATE
				FROM @xml.nodes('/root/price/item') AS a(c)
			) AS z
			INNER JOIN dbo.SystemTable ON SystemBaseName = SYS
			INNER JOIN Common.Period t ON START = DATE AND TYPE = 2
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Price.SystemPrice x
				WHERE x.ID_SYSTEM = SystemID
					AND x.ID_MONTH = t.ID
			)
			
	SET @ADD = @ADD + @@ROWCOUNT
		
	DELETE FROM dbo.BLACK_LIST_REG
		
	INSERT INTO dbo.BLACK_LIST_REG(ID_SYS, DISTR, COMP, DATE)
		SELECT SystemID, DISTR, COMP, DATE
		FROM
			(
				SELECT
					c.value('(@SYS)', 'VARCHAR(50)') AS SYS,
					c.value('(@DISTR)', 'INT') AS DISTR,
					c.value('(@COMP)', 'TINYINT') AS COMP,
					CONVERT(SMALLDATETIME, c.value('(@DATE)', 'VARCHAR(20)'), 120) AS DATE						
				FROM @xml.nodes('/root/black/item') AS a(c)
			) AS a
			INNER JOIN dbo.SystemTable b ON a.SYS = b.SystemBaseName
			
	SET @REFRESH = @REFRESH + @@ROWCOUNT
			
	DELETE FROM dbo.ExpDistr
		
	INSERT INTO dbo.ExpDistr(ID_HOST, DISTR, COMP, SET_DATE, SET_USER)
		SELECT HostID, DISTR, COMP, DATE, ''
		FROM
			(
				SELECT
					c.value('(@HOST)', 'VARCHAR(50)') AS HOST,
					c.value('(@DISTR)', 'INT') AS DISTR,
					c.value('(@COMP)', 'TINYINT') AS COMP,
					CONVERT(SMALLDATETIME, c.value('(@DATE)', 'VARCHAR(50)'), 120) AS DATE						
				FROM @xml.nodes('/root/expert/item') AS a(c)
			) AS a
			INNER JOIN dbo.Hosts c ON c.HostReg = a.HOST
			
	SET @REFRESH = @REFRESH + @@ROWCOUNT
	
	DELETE FROM dbo.HotlineDistr
		
	INSERT INTO dbo.HotlineDistr(ID_HOST, DISTR, COMP, SET_DATE, SET_USER)
		SELECT HostID, DISTR, COMP, DATE, ''
		FROM
			(
				SELECT
					c.value('(@HOST)', 'VARCHAR(50)') AS HOST,
					c.value('(@DISTR)', 'INT') AS DISTR,
					c.value('(@COMP)', 'TINYINT') AS COMP,
					CONVERT(SMALLDATETIME, c.value('(@DATE)', 'VARCHAR(50)'), 120) AS DATE						
				FROM @xml.nodes('/root/hotline/item') AS a(c)
			) AS a
			INNER JOIN dbo.Hosts c ON c.HostReg = a.HOST
			
	SET @REFRESH = @REFRESH + @@ROWCOUNT
	
	SET @OUT_DATA = 'Добавлено ' + CONVERT(NVARCHAR(32), @ADD) + ' записей, обновлено ' + CONVERT(NVARCHAR(32), @REFRESH) + ' записей'
END
