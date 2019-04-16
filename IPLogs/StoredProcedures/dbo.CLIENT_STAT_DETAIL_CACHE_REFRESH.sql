USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.CLIENT_STAT_DETAIL_CACHE_REFRESH
AS
EXECUTE [PC275-SQL\ALPHA].ClientDB.IP.sp_executesql N'TRUNCATE TABLE IP.ClientStatDetailCache'

DECLARE @t TABLE(rn INT, CSD_ID_CS INT, CSD_NUM BIGINT, CSD_SYS SMALLINT, CSD_DISTR INT, CSD_COMP SMALLINT, CSD_IP NVARCHAR(50), CSD_SESSION NVARCHAR(50), CSD_START DATETIME)

INSERT INTO @t (rn, CSD_ID_CS, CSD_NUM, CSD_SYS, CSD_DISTR, CSD_COMP, CSD_IP, CSD_SESSION, CSD_START)
SELECT
	ROW_NUMBER() OVER(PARTITION BY CSD_SYS, CSD_DISTR, CSD_COMP ORDER BY CSD_START DESC) AS rn,
	CSD_ID_CS,
	CSD_NUM, 
	CSD_SYS,
	CSD_DISTR,
	CSD_COMP,
	CSD_IP,
	CSD_SESSION,
	CSD_START
FROM
	dbo.ClientStatDetail

INSERT INTO [PC275-SQL\ALPHA].[ClientDB].[IP].[ClientStatDetailCache](CSD_ID_CS, CSD_NUM, CSD_SYS, CSD_DISTR, CSD_COMP, CSD_IP, CSD_SESSION, CSD_START)
SELECT
	CSD_ID_CS,
	CSD_NUM, 
	CSD_SYS,
	CSD_DISTR,
	CSD_COMP,
	CSD_IP,
	CSD_SESSION,
	CSD_START
FROM 
	@t
WHERE
	rn=1