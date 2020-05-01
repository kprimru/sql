USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_SUPPORT_COMPENSATION_SELECT]
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

		DECLARE @ST_GROUP VARCHAR(MAX)

		SET @ST_GROUP = ''
		SELECT @ST_GROUP = @ST_GROUP + CONVERT(VARCHAR(20), SST_ID_SUB) + ','
		FROM
			(
				SELECT DISTINCT SST_ID_SUB
				FROM dbo.SystemTypeTable
				WHERE SST_ID_SUB IS NOT NULL
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
				REG_ID_NET SMALLINT
			)

		INSERT INTO #regnode
			SELECT
				SCP_ID, SCP_ID_PERIOD, SCP_ID_SYSTEM, SCP_DISTR,
				SCP_COMP, SCP_ID_TYPE, SCP_ID_NET
			FROM Subhost.SubhostCompensationTable
			WHERE SCP_ID_PERIOD = @PERIOD
				AND SCP_ID_SUBHOST = @SUBHOST

		UPDATE t
		SET SYS_COUNT =
				(
					SELECT COUNT(*)
					FROM
						#regnode z INNER JOIN
						dbo.SystemTypeTable y ON SST_ID = REG_ID_TYPE INNER JOIN
						dbo.SystemTable x ON x.SYS_ID = REG_ID_SYSTEM --INNER JOIN
						--dbo.SystemNetCountTable ON SNC_ID = REG_ID_NET
					WHERE REG_ID_SYSTEM = t.SYS_ID
						AND SST_ID_SUB = GR_ID
						--AND SNC_ID_SN = SN_ID
						AND REG_ID_NET = SN_ID
						AND z.REG_ID_PERIOD = @PERIOD
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
						dbo.SystemTypeTable y ON SST_ID = REG_ID_TYPE INNER JOIN
						dbo.SystemTable x ON x.SYS_ID = REG_ID_SYSTEM
					WHERE REG_ID_SYSTEM = t.SYS_ID
						AND SST_ID_SUB = GR_ID
						AND z.REG_ID_PERIOD = @PERIOD
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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Subhost].[SUBHOST_SUPPORT_COMPENSATION_SELECT] TO rl_subhost_calc;
GO