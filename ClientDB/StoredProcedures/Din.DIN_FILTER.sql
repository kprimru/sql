USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Din].[DIN_FILTER]
	@SYSTEM	INT,
	@DISTR	INT,
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	SET @END = DATEADD(DAY, 1, @END)

	IF OBJECT_ID('tempdb..#din') IS NOT NULL
		DROP TABLE #din

	CREATE TABLE #din
		(
			ID			INT	IDENTITY(1, 1),
			ID_MASTER	INT,
			HST_ID		INT,
			NT_ID		INT,
			SST_ID		INT,
			DIS_STR		VARCHAR(50),
			DistrNum	INT,
			CompNum		TINYINT,
			DF_ID		INT,
			DIS_STATUS	INT
		)

	INSERT INTO #din(ID_MASTER, HST_ID, NT_ID, SST_ID, DIS_STR, DistrNum, CompNum, DF_ID, DIS_STATUS)
		SELECT 
			NULL, HostID, NT_ID, SST_ID, 
			dbo.DistrString(SystemShortName, DF_DISTR, a.DF_COMP), DF_DISTR, a.DF_COMP, ID, 
			(
				SELECT TOP 1 Service
				FROM 
					dbo.RegNodeTable p
					INNER JOIN dbo.SystemTable q ON p.SystemName = q.SystemBaseName
				WHERE q.HostID = b.HostID AND p.DistrNumber = DF_DISTR AND p.CompNumber = DF_COMP
				ORDER BY Service
			)
		FROM
			(
				SELECT DISTINCT
					(
						SELECT TOP 1 z.DF_ID
						FROM 
							Din.DinFiles z
							INNER JOIN dbo.SystemTable y ON y.SystemID = z.DF_ID_SYS
						WHERE z.DF_DISTR = x.DF_DISTR AND z.DF_COMP = x.DF_COMP AND y.HostID = t.HostID
						ORDER BY DF_CREATE DESC
					) AS ID
				FROM
					Din.DinFiles x
					INNER JOIN dbo.SystemTable t ON x.DF_ID_SYS = t.SystemID
				WHERE 
					(t.SystemID = @SYSTEM OR @SYSTEM IS NULL)
					AND (x.DF_DISTR = @DISTR OR @DISTR IS NULL)
					AND (DF_CREATE >= @BEGIN OR @BEGIN IS NULL)
					AND (DF_CREATE < @END OR @END IS NULL)
			/*LEFT OUTER JOIN dbo.RegNodeTable d ON d.SystemName = b.SystemBaseName AND d.DistrNumber = a.DF_DISTR AND d.CompNumber = a.DF_COMP*/
			) AS o_O
			INNER JOIN Din.DinFiles a ON o_O.ID = DF_ID
			INNER JOIN dbo.SystemTable b ON a.DF_ID_SYS = b.SystemID
			INNER JOIN Din.NetType ON NT_ID = DF_ID_NET
			INNER JOIN Din.SystemType ON SST_ID = DF_ID_TYPE
		
		ORDER BY SystemOrder, DF_DISTR, a.DF_COMP
				
	INSERT INTO #din(ID_MASTER, HST_ID, NT_ID, SST_ID, DIS_STR, DistrNum, CompNum, DF_ID)
		SELECT 
			(
				SELECT TOP 1 ID
				FROM #din
				WHERE HST_ID = HostID 
					AND DF_DISTR = DistrNum 
					AND DF_COMP = CompNum
				ORDER BY ID
			), HostID, DF_ID_NET, DF_ID_TYPE, 
			dbo.DistrString(SystemShortName, DF_DISTR, DF_COMP), DF_DISTR, DF_COMP, c.DF_ID
		FROM 
			#din a
			INNER JOIN dbo.SystemTable b ON HostID = HST_ID
			INNER JOIN Din.DinFiles c ON DF_ID_SYS = SystemID AND DF_DISTR = DistrNum AND DF_COMP = CompNum AND a.DF_ID <> c.DF_ID
		ORDER BY DF_CREATE DESC

	SELECT 
		a.ID, ID_MASTER, a.DF_ID, 
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
		t.DS_INDEX, Comment AS CL_NAME,
		z.Complect
	FROM
		#din a
		INNER JOIN Din.NetType c ON a.NT_ID = c.NT_ID
		INNER JOIN Din.SystemType d ON d.SST_ID = a.SST_ID
		LEFT OUTER JOIN Din.DinFiles b ON a.DF_ID = b.DF_ID
		LEFT OUTER JOIN dbo.DistrStatus t ON t.DS_REG = DIS_STATUS
		LEFT OUTER JOIN Reg.RegNodeSearchView z WITH(NOEXPAND) ON z.HostID = a.HST_ID AND a.DistrNum = z.DistrNumber AND z.CompNumber = a.CompNum
	ORDER BY z.Complect, ID


	IF OBJECT_ID('tempdb..#din') IS NOT NULL
		DROP TABLE #din
END