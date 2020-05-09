USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_SUPPORT_SELECT]
	@PERIOD	INT,
	@SUBHOST SMALLINT
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

		IF OBJECT_ID('tempdb..#system_type') IS NOT NULL
			DROP TABLE #system_type

		CREATE TABLE #system_type
			(
				SST_ID	SMALLINT	PRIMARY KEY,
				SST_CAPTION	VARCHAR(100),
				SST_ID_HOST	SMALLINT
			)


		IF @PERIOD IN (252, 253) AND @SUBHOST = 12
			INSERT INTO #system_type(SST_ID, SST_CAPTION, SST_ID_HOST)
				SELECT SST_ID, SST_CAPTION, CASE SST_ID WHEN 11 THEN 3 ELSE SST_ID_HOST END
				FROM dbo.SystemTypeTable
		ELSE
			INSERT INTO #system_type(SST_ID, SST_CAPTION, SST_ID_HOST)
				SELECT SST_ID, SST_CAPTION, SST_ID_HOST
				FROM dbo.SystemTypeTable
				WHERE NOT EXISTS
					(
						SELECT *
						FROM dbo.SystemTypeSubhost
						WHERE STS_ID_SUBHOST = @SUBHOST
							AND STS_ID_TYPE = SST_ID
					)

				UNION ALL

				SELECT SST_ID, SST_CAPTION, STS_ID_HOST
				FROM
					dbo.SystemTypeTable
					INNER JOIN dbo.SystemTypeSubhost ON STS_ID_TYPE = SST_ID
				WHERE STS_ID_SUBHOST = @SUBHOST

		DECLARE @ST_GROUP VARCHAR(MAX)

		SET @ST_GROUP = ''
		SELECT @ST_GROUP = @ST_GROUP + CONVERT(VARCHAR(20), SST_ID_HOST) + ','
		FROM
			(
				SELECT DISTINCT SST_ID_HOST
				FROM #system_type
				WHERE SST_ID_HOST IS NOT NULL
			) AS o_O

		IF @ST_GROUP <> ''
			SET @ST_GROUP = LEFT(@ST_GROUP, LEN(@ST_GROUP) - 1)

		IF OBJECT_ID('tempdb..#sgr') IS NOT NULL
			DROP TABLE #sgr

		CREATE TABLE #sgr
			(
				ID INT IDENTITY(1, 1) PRIMARY KEY,
				TITLE VARCHAR(100),
				SN_ID SMALLINT,
				TT_ID SMALLINT
			)

		INSERT INTO #sgr(TITLE, SN_ID)
			SELECT SN_NAME, SN_ID
			FROM dbo.SystemNetTable
			ORDER BY SN_COEF

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		CREATE TABLE #res
			(
				ID INT IDENTITY(1, 1) PRIMARY KEY,
				GR_ID SMALLINT,
				SGR_ID SMALLINT,
				SYS_ID SMALLINT,
				SYS_COUNT SMALLINT
			)

		INSERT INTO #res(GR_ID, SGR_ID, SYS_ID)
			SELECT Item, ID, SYS_ID
			FROM dbo.GET_TABLE_FROM_LIST(@ST_GROUP, ','), #sgr, dbo.SystemTable
			WHERE SYS_ID_SO = 1

		IF OBJECT_ID('tempdb..#regnode') IS NOT NULL
			DROP TABLE #regnode

		CREATE TABLE #regnode
			(
				REG_ID BIGINT PRIMARY KEY,
				REG_ID_PERIOD SMALLINT,
				REG_ID_SYSTEM SMALLINT,
				REG_DISTR_NUM INT,
				REG_COMP_NUM TINYINT,
				REG_ID_TYPE SMALLINT,
				REG_ID_NET SMALLINT,
				REG_ID_STATUS SMALLINT
			)

		INSERT INTO #regnode
			SELECT
				REG_ID, REG_ID_PERIOD, REG_ID_SYSTEM, REG_DISTR_NUM,
				REG_COMP_NUM, REG_ID_TYPE, REG_ID_NET, REG_ID_STATUS
			FROM dbo.PeriodRegTable INNER JOIN dbo.SystemTypeTable ON SST_ID = REG_ID_TYPE
			WHERE REG_ID_PERIOD = @PERIOD
				AND REG_ID_HOST = @SUBHOST
				AND SST_NAME <> 'NCT'
				AND NOT EXISTS
					(
						SELECT *
						FROM Subhost.Diu
						WHERE DIU_ID_SYSTEM = REG_ID_SYSTEM
							AND DIU_DISTR = REG_DISTR_NUM
							AND DIU_COMP = REG_COMP_NUM
					)

			UNION

			SELECT
				REG_ID, REG_ID_PERIOD, REG_ID_SYSTEM, REG_DISTR_NUM,
				REG_COMP_NUM, REG_ID_TYPE, REG_ID_NET, REG_ID_STATUS
			FROM
				dbo.PeriodRegTable
				INNER JOIN Subhost.Diu ON DIU_ID_SYSTEM = REG_ID_SYSTEM
										AND REG_DISTR_NUM = DIU_DISTR
										AND	REG_COMP_NUM = DIU_COMP
			WHERE REG_ID_PERIOD = @PERIOD
				AND DIU_ID_SUBHOST = @SUBHOST
				AND DIU_ACTIVE = 1

		UPDATE t
		SET SYS_COUNT =
				(
					SELECT COUNT(*)
					FROM
						#regnode z INNER JOIN
						#system_type y ON SST_ID = REG_ID_TYPE INNER JOIN
						dbo.SystemTable x ON x.SYS_ID = REG_ID_SYSTEM INNER JOIN
						dbo.SystemNetCountTable ON SNC_ID = REG_ID_NET INNER JOIN
						dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
					WHERE REG_ID_SYSTEM = t.SYS_ID
						AND SST_ID_HOST = GR_ID
						AND SNC_ID_SN = SN_ID
						AND z.REG_ID_PERIOD = @PERIOD
						AND DS_REG = 0
				)
		FROM
			#res t INNER JOIN
			#sgr a ON a.ID = t.SGR_ID
		WHERE SN_ID IS NOT NULL

		UPDATE t
		SET SYS_COUNT =
				(
					SELECT COUNT(*)
					FROM
						#regnode z INNER JOIN
						#system_type y ON SST_ID = REG_ID_TYPE INNER JOIN
						dbo.SystemTable x ON x.SYS_ID = REG_ID_SYSTEM INNER JOIN
						dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
					WHERE REG_ID_SYSTEM = t.SYS_ID
						AND SST_ID_HOST = GR_ID
						AND z.REG_ID_PERIOD = @PERIOD
						AND DS_REG = 0
				)
		FROM
			#res t INNER JOIN
			#sgr a ON a.ID = t.SGR_ID
		WHERE TT_ID IS NOT NULL

		SELECT SST_ID, /*c.SYS_ID, */SYS_SHORT_NAME, TITLE, SYS_COUNT
		FROM
			#res a INNER JOIN
			#sgr b ON a.SGR_ID = b.ID INNER JOIN
			dbo.SystemTable c ON c.SYS_ID = a.SYS_ID INNER JOIN
			dbo.SystemTypeTable ON SST_ID = a.GR_ID
		WHERE SYS_COUNT <> 0
		ORDER BY SST_ORDER, SYS_ORDER, b.ID

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		IF OBJECT_ID('tempdb..#sgr') IS NOT NULL
			DROP TABLE #sgr

		IF OBJECT_ID('tempdb..#regnode') IS NOT NULL
			DROP TABLE #regnode

		IF OBJECT_ID('tempdb..#system_type') IS NOT NULL
			DROP TABLE #system_type

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_SUPPORT_SELECT] TO rl_subhost_calc;
GO