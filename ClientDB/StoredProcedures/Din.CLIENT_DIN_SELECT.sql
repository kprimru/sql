USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Din].[CLIENT_DIN_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @ClientDistrs Table
	(
		Host_Id		SmallInt	NOT NULL,
		Distr		Int			NOT NULL,
		Comp		TinyInt		NOT NULL,
		DF_ID		Int				NULL,
		System_Id	SmallInt		NULL,
		PRIMARY KEY CLUSTERED(Distr, Host_Id, Comp)
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO @ClientDistrs(Host_Id, Distr, Comp)
			SELECT HostID, DISTR, COMP
			FROM  dbo.ClientDistrView a WITH(NOEXPAND)
			WHERE a.ID_CLIENT = @CLIENT;

		INSERT INTO @ClientDistrs(Host_Id, Distr, Comp)
		SELECT HostID, DistrNumber, CompNumber
		FROM Reg.RegNodeSearchView AS A WITH(NOEXPAND)
		WHERE NOT EXISTS
			(
				SELECT *
				FROM @ClientDistrs c
				WHERE c.Host_Id = A.HostID
					AND c.Distr = A.DistrNumber
					AND c.Comp = A.CompNumber
			)
			AND a.Complect IN
				(
					SELECT DISTINCT Complect
					FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
					INNER JOIN @ClientDistrs x ON x.Host_Id = z.HostID AND x.Distr = z.DistrNumber AND x.Comp = z.CompNumber
				)
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.ClientDistrView c WITH(NOEXPAND)
					WHERE c.DISTR = a.DistrNumber AND c.COMP = a.CompNumber AND A.HostID = c.HostID
						AND c.ID_CLIENT <> @CLIENT
				);


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
				DIS_STATUS	INT,
				PRIMARY KEY CLUSTERED (ID)
			);

		UPDATE x
		SET DF_ID =
				(
					SELECT TOP 1 z.DF_ID
					FROM Din.DinFiles z
					INNER JOIN Reg.RegNodeSearchView q WITH(NOEXPAND) ON DistrNumber = z.DF_DISTR AND CompNumber = z.DF_COMP AND z.DF_ID_SYS = q.SystemId AND z.DF_ID_NET = q.NT_ID
					WHERE z.DF_DISTR = x.DISTR AND z.DF_COMP = x.COMP AND q.HostID = X.Host_ID
					ORDER BY DF_CREATE DESC
				)
		FROM @ClientDistrs X;

		UPDATE D
		SET System_Id =
			(
				SELECT TOP 1 SystemID
				FROM
					(
						SELECT a.SystemID, SystemOrder
						FROM dbo.ClientDistrView a WITH(NOEXPAND)
						WHERE a.HostID = D.Host_Id AND a.DISTR = D.DISTR AND a.COMP = D.COMP

						UNION

						SELECT SystemID, SystemOrder
						FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
						WHERE a.HostID = D.Host_Id AND a.DistrNumber = D.DISTR AND a.CompNumber = D.COMP
					) AS o_O
				ORDER BY SystemOrder
			)
		FROM @ClientDistrs AS D;


		INSERT INTO #din(ID_MASTER, HST_ID, ID_SYSTEM, NT_ID, SST_ID, DIS_STR, DistrNum, CompNum, DF_ID, DIS_STATUS)
		SELECT
			NULL, ISNULL(b.HostID, c.HostID), ISNULL(b.SystemID, c.SystemID), NT_ID, SST_ID,
			dbo.DistrString(ISNULL(b.SystemShortName, c.SystemShortName), DISTR, COMP), DISTR AS DF_DISTR, COMP AS DF_COMP, t.DF_ID,
			(
				SELECT TOP 1 Service
				FROM Reg.RegNodeSearchView p WITH(NOEXPAND)
				WHERE p.HostID = b.HostID AND p.DistrNumber = DISTR AND p.CompNumber = COMP
				ORDER BY Service
			)
		FROM @ClientDistrs AS T
		LEFT OUTER JOIN Din.DinFiles a ON t.DF_ID = a.DF_ID
		LEFT OUTER JOIN dbo.SystemTable b ON a.DF_ID_SYS = b.SystemID
		LEFT OUTER JOIN dbo.SystemTable c ON t.System_Id = c.SystemID
		LEFT OUTER JOIN Din.NetType ON NT_ID = DF_ID_NET
		LEFT OUTER JOIN Din.SystemType ON SST_ID = DF_ID_TYPE
		ORDER BY ISNULL(b.SystemOrder, c.SystemOrder), DISTR, COMP;

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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Din].[CLIENT_DIN_SELECT] TO rl_din_client_only;
GRANT EXECUTE ON [Din].[CLIENT_DIN_SELECT] TO rl_din_r;
GO