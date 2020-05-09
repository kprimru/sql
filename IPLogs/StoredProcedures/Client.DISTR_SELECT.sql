USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[DISTR_SELECT]
	@CLIENTID		INT,
	@CLIENT_TYPE	NVARCHAR(20) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	IF @CLIENT_TYPE = 'OIS'
	BEGIN
		SELECT
			SystemShortName,
			CONVERT(VARCHAR(20), DISTR) +
			CASE a.COMP
				WHEN 1 THEN ''
				ELSE '/' + CONVERT(VARCHAR(20), a.COMP)
			END AS DistrNumber,
			SystemTypeName, DistrTypeName, a.DS_NAME AS ServiceStatusName, DS_INDEX AS ServiceStatusIndex,
			ISNULL(a.DS_NAME, 'Неизвестно')  AS RN_STATUS,
			CASE ISNULL(TT_REG, -1)
				WHEN -1 THEN 'Неизвестно'
				WHEN 0 THEN SN_NAME +
					CASE SNC_NET_COUNT
						WHEN 0 THEN ''
						WHEN 1 THEN ''
						ELSE ' ' + CONVERT(VARCHAR(50), SNC_NET_COUNT)
					END
				ELSE TT_NAME
			END AS RN_NET_TECH
		FROM
			[PC275-SQL\ALPHA].ClientDB.dbo.ClientDistrView a INNER JOIN
			--[PC275-SQL\ALPHA].ClientDB.dbo.SystemTable b ON a.SystemID = b.SystemID INNER JOIN
			--[PC275-SQL\ALPHA].ClientDB.dbo.SystemTypeTable c ON c.SystemTypeID = a.SystemTypeID INNER JOIN
			--[PC275-SQL\ALPHA].ClientDB.dbo.DistrTypeTable d ON d.DistrTypeID = a.DistrTypeID INNER JOIN
			--[PC275-SQL\ALPHA].ClientDB.dbo.DistrStatus e ON e.DS_ID = a.DS_ID LEFT OUTER JOIN
			[PC275-SQL\ALPHA].ClientDB.dbo.RegNodeTable f ON f.SystemName = a.SystemBaseName
								AND f.DistrNumber = a.DISTR
								AND f.CompNumber = a.COMP LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.DistrStatusTable g ON g.DS_REG = f.Service LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.SystemNetCountTable h ON h.SNC_NET_COUNT = f.NetCount LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.SystemNetTable j ON j.SN_ID = h.SNC_ID_SN LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.TechnolTypeTable k ON k.TT_REG = TechnolType
		WHERE ID_CLIENT = @CLIENTID
		ORDER BY SystemOrder
	END
	ELSE IF @CLIENT_TYPE = 'DBF'
	BEGIN
		SELECT
			SYS_SHORT_NAME AS SystemShortName,
			CONVERT(VARCHAR(20), DIS_NUM) +
			CASE DIS_COMP_NUM
				WHEN 1 THEN ''
				ELSE '/' + CONVERT(VARCHAR(20), DIS_COMP_NUM)
			END AS DistrNumber,
			NULL SystemTypeName, NULL DistrTypeName, NULL ServiceStatusName, NULL ServiceStatusIndex,
			ISNULL(DS_NAME, 'Неизвестно') AS RN_STATUS,
			CASE ISNULL(TT_REG, -1)
				WHEN -1 THEN 'Неизвестно'
				WHEN 0 THEN SN_NAME +
					CASE SNC_NET_COUNT
						WHEN 0 THEN ''
						WHEN 1 THEN ''
						ELSE ' ' + CONVERT(VARCHAR(50), SNC_NET_COUNT)
					END
				ELSE TT_NAME
			END AS RN_NET_TECH
		FROM
			[PC275-SQL\DELTA].DBF.dbo.TOTable a INNER JOIN
			[PC275-SQL\DELTA].DBF.dbo.TODistrTable b ON TD_ID_TO = TO_ID INNER JOIN
			[PC275-SQL\DELTA].DBF.dbo.DistrView c ON DIS_ID = TD_ID_DISTR INNER JOIN
			[PC275-SQL\ALPHA].ClientDB.dbo.RegNodeTable f ON f.SystemName = c.SYS_REG_NAME
								AND f.DistrNumber = c.DIS_NUM
								AND f.CompNumber = c.DIS_COMP_NUM LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.DistrStatusTable g ON g.DS_REG = f.Service LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.SystemNetCountTable h ON h.SNC_NET_COUNT = f.NetCount LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.SystemNetTable j ON j.SN_ID = h.SNC_ID_SN LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.TechnolTypeTable k ON k.TT_REG = TechnolType
		WHERE TO_ID = @CLIENTID
		ORDER BY SYS_ORDER
	END
	ELSE IF @CLIENT_TYPE = 'REG'
		SELECT
			SYS_SHORT_NAME AS SystemShortName,
			CONVERT(VARCHAR(20), DistrNumber) +
			CASE CompNumber
				WHEN 1 THEN ''
				ELSE '/' + CONVERT(VARCHAR(20), CompNumber)
			END AS DistrNumber,
			NULL SystemTypeName, NULL DistrTypeName, NULL ServiceStatusName, NULL ServiceStatusIndex,
			ISNULL(DS_NAME, 'Неизвестно') AS RN_STATUS,
			CASE ISNULL(TT_REG, -1)
				WHEN -1 THEN 'Неизвестно'
				WHEN 0 THEN SN_NAME +
					CASE SNC_NET_COUNT
						WHEN 0 THEN ''
						WHEN 1 THEN ''
						ELSE ' ' + CONVERT(VARCHAR(50), SNC_NET_COUNT)
					END
				ELSE TT_NAME
			END AS RN_NET_TECH
		FROM
			[PC275-SQL\ALPHA].ClientDB.dbo.RegNodeTable f LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.SystemTable z ON z.SYS_REG_NAME = f.SystemName LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.DistrStatusTable g ON g.DS_REG = f.Service LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.SystemNetCountTable h ON h.SNC_NET_COUNT = f.NetCount LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.SystemNetTable j ON j.SN_ID = h.SNC_ID_SN LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.TechnolTypeTable k ON k.TT_REG = TechnolType
		WHERE ID = @CLIENTID
		ORDER BY SYS_ORDER
	ELSE 
		SELECT
			NULL AS SystemShortName,
			NULL AS DistrNumber,
			NULL AS SystemTypeName,
			NULL AS DistrTypeName,
			NULL AS ServiceStatusName,
			NULL AS ServiceStatusIndex,
			NULL AS RN_STATUS,
			NULL AS RN_NET_TECH
END
GO
GRANT EXECUTE ON [Client].[DISTR_SELECT] TO rl_client_distr;
GO