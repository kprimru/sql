USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reg].[ONLINE_DISTR_SELECT]
	@REGISTER	BIT,
	@FREE		BIT,
	@MAIN		BIT,
	@DISTR		INT,
	@SYSTEM		INT,
	@NAME		NVARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#res') IS NOT NULL
		DROP TABLE #res
		
	CREATE TABLE #res
		(
			ID_HOST		INT,
			ID_SYSTEM	INT,
			DISTR		INT,
			COMP		TINYINT,
			ID_SST		INT,
			ID_NET		INT,
			TP			TINYINT
		)
		
		
	IF @REGISTER = 1
		INSERT INTO #res(ID_HOST, ID_SYSTEM, DISTR, COMP, ID_SST, ID_NET, TP)
			SELECT HostID, SystemID, DistrNumber, CompNumber, SST_ID, NT_ID, 1
			FROM Reg.RegNodeSearchView WITH(NOEXPAND)
			WHERE NT_TECH IN (3, 6, 9)
			
	IF @FREE = 1
		INSERT INTO #res(ID_HOST, ID_SYSTEM, DISTR, COMP, ID_SST, ID_NET, TP)
			SELECT HostID, SystemID, DF_DISTR, DF_COMP, DF_ID_TYPE, DF_ID_NET, 2
			FROM 
				Din.DinFiles a
				INNER JOIN Din.NetType b ON DF_ID_NET = NT_ID
				--INNER JOIN dbo.ClientDistrTable
				INNER JOIN dbo.SystemTable c ON c.SystemID = DF_ID_SYS
			WHERE NT_TECH IN (3, 6, 9)
				AND NOT EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
					WHERE a.DF_DISTR = z.DistrNumber AND a.DF_COMP = z.CompNumber AND c.HostID = z.HostID
				)
				AND NOT EXISTS
				(
					SELECT *
					FROM #res z
					WHERE z.ID_HOST = c.HostID AND z.DISTR = a.DF_DISTR AND z.COMP = a.DF_COMP
				)
				
	IF @MAIN = 1
		DELETE FROM #res
		WHERE ID_SYSTEM NOT IN 
			(
				SELECT SystemID 
				FROM 
					dbo.SystemTable a 
					INNER JOIN dbo.Hosts b ON a.HostID = b.HostID 
				WHERE b.HostReg = 'LAW'
			)	
		
	IF @DISTR IS NOT NULL
		DELETE FROM #res
		WHERE DISTR <> @DISTR
		
	IF @SYSTEM IS NOT NULL
		DELETE FROM #res
		WHERE ID_SYSTEM <> @SYSTEM
				
	
				
	SELECT
		d.ID, 
		dbo.DistrString(b.SystemShortName, a.DISTR, a.COMP) AS DIS_STR,
		a.ID_SYSTEM, a.ID_HOST, a.DISTR, a.COMP, c.SST_SHORT, f.NT_SHORT,
		TP, d.PASS, e.RegisterDate, e.Comment
	FROM 
		#res a
		INNER JOIN dbo.SystemTable b ON a.ID_SYSTEM = b.SystemID
		INNER JOIN Din.SystemType c ON c.SST_ID = a.ID_SST
		INNER JOIN Din.NetType f ON f.NT_ID = a.ID_NET
		LEFT OUTER JOIN Reg.OnlinePassword d ON d.ID_SYSTEM = a.ID_SYSTEM AND d.DISTR = a.DISTR AND d.COMP = a.COMP AND d.STATUS = 1
		LEFT OUTER JOIN Reg.RegNodeSearchView e WITH(NOEXPAND) ON e.SystemID = a.ID_SYSTEM AND e.DistrNumber = a.DISTR AND e.CompNumber = a.COMP
	WHERE (@NAME IS NULL OR e.Comment LIKE @NAME) AND c.SST_SHORT = 'ÄÑÏ'
	ORDER BY TP, b.SystemOrder, a.DISTR, a.COMP
		
	IF OBJECT_ID('tempdb..#res') IS NOT NULL
		DROP TABLE #res
END
