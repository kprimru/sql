USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Din].[CLIENT_DIN_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client

	CREATE TABLE #client
		(
			HST_ID	INT,
			DISTR	INT,
			COMP	TINYINT,
			DF_ID	BIGINT,
			SYS_ID	INT
		)

	INSERT INTO #client(HST_ID, DISTR, COMP)
		SELECT HostID, DISTR, COMP
		FROM 
			dbo.ClientDistrView a WITH(NOEXPAND)			
		WHERE a.ID_CLIENT = @CLIENT

	INSERT INTO #client(HST_ID, DISTR, COMP)
		SELECT HostID, DistrNumber, CompNumber
		FROM 
			dbo.RegNodeTable a
			INNER JOIN dbo.SystemTable b ON b.SystemBaseName = a.SystemName
		WHERE NOT EXISTS
			(
				SELECT *
				FROM #client c
				WHERE c.HST_ID = b.HostID
					AND a.DistrNumber = c.DISTR
					AND a.CompNumber = c.COMP
			)
			AND a.Complect IN
				(
					SELECT DISTINCT Complect
					FROM 
						dbo.RegNodeTable z
						INNER JOIN dbo.SystemTable y ON z.SystemName = y.SystemBaseName
						INNER JOIN #client x ON x.HST_ID = y.HostID AND x.DISTR = z.DistrNumber AND x.COMP = z.CompNumber
				)
			AND NOT EXISTS
				(
					SELECT *
					FROM 
						dbo.ClientDistrView c WITH(NOEXPAND)						
					WHERE c.DISTR = a.DistrNumber AND c.COMP = a.CompNumber AND b.HostID = c.HostID
						AND c.ID_CLIENT <> @CLIENT
				)


	IF OBJECT_ID('tempdb..#din') IS NOT NULL
		DROP TABLE #din

	CREATE TABLE #din
		(
			ID			INT	IDENTITY(1, 1),
			ID_MASTER	INT,
			HST_ID		INT,
			ID_SYSTEM	INT,
			NT_ID		INT,
			SST_ID		INT,
			DIS_STR		VARCHAR(50),
			DistrNum	INT,
			CompNum		TINYINT,
			DF_ID		INT,
			DIS_STATUS	INT
		)

	UPDATE x
	SET DF_ID = (
					SELECT TOP 1 z.DF_ID
					FROM 
						Din.DinFiles z
						INNER JOIN dbo.SystemTable y ON y.SystemID = z.DF_ID_SYS
						INNER JOIN Din.NetType ON NT_ID = DF_ID_NET						
						INNER JOIN dbo.RegNodeTable q ON DistrNumber = z.DF_DISTR AND CompNumber = z.DF_COMP AND y.SYstemBaseName = q.SystemName AND NetCount = NT_NET AND TechnolType = NT_TECH AND ODON = NT_ODON AND ODOFF = NT_ODOFF
					WHERE z.DF_DISTR = x.DISTR AND z.DF_COMP = x.COMP AND y.HostID = t.HostID
					ORDER BY DF_CREATE DESC
				)
	FROM
		dbo.SystemTable t
		INNER JOIN #client x ON x.HST_ID = t.HostID

	UPDATE #client
	SET SYS_ID = 
			(
				SELECT TOP 1 SystemID
				FROM
					(
						SELECT a.SystemID, SystemOrder
						FROM 
							dbo.ClientDistrView a WITH(NOEXPAND)
						WHERE a.HostID = HST_ID AND a.DISTR = #client.DISTR AND a.COMP = #client.COMP

						UNION
	
						SELECT SystemID, SystemOrder
						FROM 
							dbo.RegNodeTable a
							INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
						WHERE b.HostID = HST_ID AND a.DistrNumber = DISTR AND a.CompNumber = COMP
					) AS o_O
				ORDER BY SystemOrder
			)
	

	INSERT INTO #din(ID_MASTER, HST_ID, ID_SYSTEM, NT_ID, SST_ID, DIS_STR, DistrNum, CompNum, DF_ID, DIS_STATUS)
		SELECT 
			NULL, ISNULL(b.HostID, c.HostID), ISNULL(b.SystemID, c.SystemID), NT_ID, SST_ID, 
			dbo.DistrString(ISNULL(b.SystemShortName, c.SystemShortName), DISTR, COMP), DISTR AS DF_DISTR, COMP AS DF_COMP, t.DF_ID,
			(
				SELECT TOP 1 Service
				FROM 
					dbo.RegNodeTable p
					INNER JOIN dbo.SystemTable q ON p.SystemName = q.SystemBaseName
				WHERE q.HostID = b.HostID AND p.DistrNumber = DISTR AND p.CompNumber = COMP
				ORDER BY Service
			)
		FROM
			#client t			
			LEFT OUTER JOIN Din.DinFiles a ON t.DF_ID = a.DF_ID			
			LEFT OUTER JOIN dbo.SystemTable b ON a.DF_ID_SYS = b.SystemID
			LEFT OUTER JOIN dbo.SystemTable c ON t.SYS_ID = c.SystemID
			LEFT OUTER JOIN Din.NetType ON NT_ID = DF_ID_NET
			LEFT OUTER JOIN Din.SystemType ON SST_ID = DF_ID_TYPE
		
		ORDER BY ISNULL(b.SystemOrder, c.SystemOrder), DISTR, COMP					

	INSERT INTO #din(ID_MASTER, HST_ID, ID_SYSTEM, NT_ID, SST_ID, DIS_STR, DistrNum, CompNum, DF_ID)
		SELECT 
			(
				SELECT TOP 1 ID
				FROM #din
				WHERE HST_ID = HostID 
					AND DF_DISTR = DistrNum 
					AND DF_COMP = CompNum
				ORDER BY ID
			), HostID, SystemID, DF_ID_NET, DF_ID_TYPE, 
			dbo.DistrString(SystemShortName, DF_DISTR, DF_COMP), DF_DISTR, DF_COMP, c.DF_ID
		FROM 
			#din a
			INNER JOIN dbo.SystemTable b ON HostID = HST_ID
			INNER JOIN Din.DinFiles c ON DF_ID_SYS = SystemID AND DF_DISTR = DistrNum AND DF_COMP = CompNum AND a.DF_ID <> c.DF_ID
		ORDER BY DF_CREATE DESC

	IF IS_MEMBER('rl_din_client_only') = 1
		DELETE FROM #din WHERE ID_MASTER IS NOT NULL

	SELECT 
		a.ID, ID_MASTER, a.DF_ID, a.NT_ID, a.SST_ID, ID_SYSTEM, DistrNum, CompNum,
		CONVERT(BIT, CASE 
			WHEN ID_MASTER IS NULL AND a.DF_ID IS NOT NULL AND ISNULL(DIS_STATUS, -1) = 0 THEN 1
			ELSE 0
		END) AS DF_SELECT,
		DIS_STR, 
		NT_NAME + 
			CASE NT_NOTE
				WHEN '' THEN ''
				ELSE '(' + NT_NOTE + ')'
			END AS NT_NAME, 
		SST_NAME + 
			CASE SST_NOTE 
				WHEN '' THEN ''
				ELSE '(' + SST_NOTE + ')'
			END AS SST_NAME,
		DF_CREATE, CASE WHEN ID_MASTER IS NULL THEN DIS_STATUS ELSE NULL END AS DIS_STATUS,
		s.DS_INDEX, '' AS CL_NAME, z.Complect
	FROM
		#din a
		LEFT OUTER JOIN Din.NetType c ON a.NT_ID = c.NT_ID
		LEFT OUTER JOIN Din.SystemType d ON d.SST_ID = a.SST_ID
		LEFT OUTER JOIN Din.DinFiles b ON a.DF_ID = b.DF_ID
		LEFT OUTER JOIN dbo.DistrStatus s ON DS_REG = DIS_STATUS
		LEFT OUTER JOIN Reg.RegNodeSearchView z WITH(NOEXPAND) ON z.HostID = a.HST_ID AND a.DistrNum = z.DistrNumber AND z.CompNumber = a.CompNum
	ORDER BY DIS_STATUS, a.ID


	IF OBJECT_ID('tempdb..#din') IS NOT NULL
		DROP TABLE #din

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
END