USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DISTR_PROFILE_LOAD]
	@MONTH	UNIQUEIDENTIFIER,
	@DATA	NVARCHAR(MAX)
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

		DECLARE @XML XML
		SET @XML = CAST(@DATA AS XML)

		IF OBJECT_ID('tempdb..#profile') IS NOT NULL
			DROP TABLE #profile

		CREATE TABLE #profile
			(
				DISTR		INT,
				COMP		TINYINT,
				SYS			NVARCHAR(32),
				NET			NVARCHAR(64),
				USR			SMALLINT,
				ERR			SMALLINT,
				PROBLEM		DECIMAL(8, 2),
				BUH			SMALLINT,
				JUR			SMALLINT,
				BUD			SMALLINT,
				TENDER		SMALLINT,
				KADR		SMALLINT,
				UNIVERSE	SMALLINT
			)

		INSERT INTO #profile(DISTR, COMP, SYS, NET, USR, ERR, PROBLEM, BUH, JUR, BUD, TENDER, KADR, UNIVERSE)
			SELECT 
				CASE CHARINDEX('/', DIS_S) WHEN 0 THEN CONVERT(INT, DIS_S) ELSE CONVERT(INT, LEFT(DIS_S, CHARINDEX('/', DIS_S) - 1)) END AS DISTR,
				CASE CHARINDEX('/', DIS_S) WHEN 0 THEN 1 ELSE CONVERT(INT, RIGHT(DIS_S, LEN(DIS_S) - CHARINDEX('/', DIS_S))) END AS COMP,
				SYS, NET, USR, ERROR, 
				CASE CHARINDEX(',', PROBLEM) WHEN 0 THEN CONVERT(DECIMAL(8, 4), PROBLEM) * 100 ELSE CONVERT(DECIMAL(8, 4), REPLACE(PROBLEM, ',', '.')) * 100 END AS PROBLEM, 
				BUH, JUR, BUD, TENDER, KADR, UNIVERSE		
			FROM
				(
					SELECT 
						c.value('@distr[1]', 'NVARCHAR(64)') AS DIS_S, 
						c.value('@sys[1]', 'NVARCHAR(64)') AS SYS, 
						c.value('@net[1]', 'NVARCHAR(64)') AS NET, 
						c.value('@usercount[1]', 'SMALLINT') AS USR, 
						c.value('@buhcount[1]', 'SMALLINT') AS BUH, 
						c.value('@jurcount[1]', 'SMALLINT') AS JUR, 
						c.value('@budcount[1]', 'SMALLINT') AS BUD, 
						c.value('@tendercount[1]', 'SMALLINT') AS TENDER,
						c.value('@kadrcount[1]', 'SMALLINT') AS KADR, 
						c.value('@universecount[1]', 'SMALLINT') AS UNIVERSE, 
						c.value('@errorcount[1]', 'SMALLINT') AS ERROR, 
						c.value('@problem[1]', 'NVARCHAR(64)') AS PROBLEM
					FROM @XML.nodes('root[1]/item') AS a(c)
				) AS a
			
		DELETE FROM dbo.DistrProfileDetail
		WHERE ID_MASTER IN (SELECT ID FROM dbo.DistrProfile WHERE ID_PERIOD = @MONTH)
		
		DELETE FROM dbo.DistrProfile
		WHERE ID_PERIOD = @MONTH
			
		INSERT INTO dbo.DistrProfile(ID_PERIOD, SYS_NAME, NET, DISTR, COMP, USR_COUNT, ERR_COUNT, PROBLEM_PRC)
			SELECT @MONTH, SYS, NET, DISTR, COMP, USR, ERR, PROBLEM
			FROM #profile

		INSERT INTO dbo.DistrProfileDetail(ID_MASTER, ID_PROFILE, CNT)
			SELECT 
				(
					SELECT TOP 1 ID
					FROM dbo.DistrProfile z
					WHERE z.ID_PERIOD = @MONTH
						AND z.SYS_NAME = a.SYS
						AND z.DISTR = a.DISTR
						AND z.COMP = a.COMP
				), 
				(
					SELECT ID
					FROM dbo.ProfileType
					WHERE NAME = 'Бухгалтерия и кадры'
				),
				BUH
			FROM #profile a
			WHERE a.BUH <> 0
			
		INSERT INTO dbo.DistrProfileDetail(ID_MASTER, ID_PROFILE, CNT)
			SELECT 
				(
					SELECT TOP 1 ID
					FROM dbo.DistrProfile z
					WHERE z.ID_PERIOD = @MONTH
						AND z.SYS_NAME = a.SYS
						AND z.DISTR = a.DISTR
						AND z.COMP = a.COMP
				), 
				(
					SELECT ID
					FROM dbo.ProfileType
					WHERE NAME = 'Юрист'
				),
				JUR
			FROM #profile a
			WHERE a.JUR <> 0
			
		INSERT INTO dbo.DistrProfileDetail(ID_MASTER, ID_PROFILE, CNT)
			SELECT 
				(
					SELECT TOP 1 ID
					FROM dbo.DistrProfile z
					WHERE z.ID_PERIOD = @MONTH
						AND z.SYS_NAME = a.SYS
						AND z.DISTR = a.DISTR
						AND z.COMP = a.COMP
				), 
				(
					SELECT ID
					FROM dbo.ProfileType
					WHERE NAME = 'Бухгалтерия и кадры БО'
				),
				BUD
			FROM #profile a
			WHERE a.BUD <> 0
			
		INSERT INTO dbo.DistrProfileDetail(ID_MASTER, ID_PROFILE, CNT)
			SELECT 
				(
					SELECT TOP 1 ID
					FROM dbo.DistrProfile z
					WHERE z.ID_PERIOD = @MONTH
						AND z.SYS_NAME = a.SYS
						AND z.DISTR = a.DISTR
						AND z.COMP = a.COMP
				), 
				(
					SELECT ID
					FROM dbo.ProfileType
					WHERE NAME = 'Кадры'
				),
				KADR
			FROM #profile a
			WHERE a.KADR <> 0
			
		INSERT INTO dbo.DistrProfileDetail(ID_MASTER, ID_PROFILE, CNT)
			SELECT 
				(
					SELECT TOP 1 ID
					FROM dbo.DistrProfile z
					WHERE z.ID_PERIOD = @MONTH
						AND z.SYS_NAME = a.SYS
						AND z.DISTR = a.DISTR
						AND z.COMP = a.COMP
				), 
				(
					SELECT ID
					FROM dbo.ProfileType
					WHERE NAME = 'Специалист по закупкам'
				),
				TENDER
			FROM #profile a
			WHERE a.TENDER <> 0
			
		INSERT INTO dbo.DistrProfileDetail(ID_MASTER, ID_PROFILE, CNT)
			SELECT 
				(
					SELECT TOP 1 ID
					FROM dbo.DistrProfile z
					WHERE z.ID_PERIOD = @MONTH
						AND z.SYS_NAME = a.SYS
						AND z.DISTR = a.DISTR
						AND z.COMP = a.COMP
				), 
				(
					SELECT ID
					FROM dbo.ProfileType
					WHERE NAME = 'Универсальный'
				),
				UNIVERSE
			FROM #profile a
			WHERE a.UNIVERSE <> 0
			
		IF OBJECT_ID('tempdb..#profile') IS NOT NULL
			DROP TABLE #profile
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
