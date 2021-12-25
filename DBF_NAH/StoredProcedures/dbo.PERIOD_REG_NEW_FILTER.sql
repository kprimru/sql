USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PERIOD_REG_NEW_FILTER]
  @rnnidperiods		varchar(MAX),
  @rnnidsystems		varchar(MAX),
  @rnndistrnum		int,
--  @rnncompnum		tinyint,
  @rnnidhosts		varchar(MAX),
  @rnnidtypes		varchar(MAX),
  @beg_rnndate		smalldatetime,
  @end_rnndate		smalldatetime,
  @beg_rnndateon	smalldatetime,
  @end_rnndateon	smalldatetime,
  @rnnidnets		varchar(MAX),
  @rnnnumclient		int,
  @rnnpsedo			varchar(50),
  @rnncomment		varchar(50),
  @regidtechtype	VARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		-----------
		--ПЕРИОДЫ--
		-----------
		IF OBJECT_ID('tempdb..#periods') IS NOT NULL
			DROP TABLE #periods

		CREATE TABLE #periods
			(
				period_id INT NOT NULL
			)

		IF @rnnidperiods IS NULL
		BEGIN
			INSERT INTO #periods
				SELECT PR_ID FROM dbo.PeriodTable
		END
		ELSE
		BEGIN
			INSERT INTO #periods
				SELECT *
				FROM dbo.GET_TABLE_FROM_LIST(@rnnidperiods, ',')
		END

		-----------
		--СИСТЕМЫ--
		-----------
		IF OBJECT_ID('tempdb..#systems') IS NOT NULL
			DROP TABLE #systems
		CREATE TABLE #systems ( system_id INT NOT NULL )
		IF @rnnidsystems IS NULL BEGIN
			INSERT INTO #systems SELECT SYS_ID FROM dbo.SystemTable
		END
		ELSE BEGIN
			INSERT INTO #systems SELECT * FROM dbo.GET_TABLE_FROM_LIST(@rnnidsystems, ',')
		END

		------------
		--ПОДХОСТЫ--
		------------
		IF OBJECT_ID('tempdb..#subhosts') IS NOT NULL
			DROP TABLE #subhosts
		CREATE TABLE #subhosts ( subhost_id INT NOT NULL )
		IF @rnnidhosts IS NULL BEGIN
			INSERT INTO #subhosts SELECT SH_ID FROM dbo.SubhostTable
		END
		ELSE BEGIN
			INSERT INTO #subhosts SELECT * FROM dbo.GET_TABLE_FROM_LIST(@rnnidhosts, ',')
		END

		---------------
		--ТИПЫ СИСТЕМ--
		---------------
		IF OBJECT_ID('tempdb..#systemtypes') IS NOT NULL
			DROP TABLE #systemtypes
		CREATE TABLE #systemtypes ( system_type_id INT NOT NULL )
		IF @rnnidtypes IS NULL BEGIN
			INSERT INTO #systemtypes SELECT SST_ID FROM dbo.SystemTypeTable
		END
		ELSE BEGIN
			INSERT INTO #systemtypes SELECT * FROM dbo.GET_TABLE_FROM_LIST(@rnnidtypes, ',')
		END

		-------------
		--NET COUNT--
		-------------
		IF OBJECT_ID('tempdb..#netcounts') IS NOT NULL
			DROP TABLE #netcounts
		CREATE TABLE #netcounts ( nc_id INT NOT NULL )
		IF @rnnidnets IS NULL BEGIN
			INSERT INTO #netcounts SELECT SNC_ID FROM dbo.SystemNetCountTable
		END
		ELSE BEGIN
			INSERT INTO #netcounts SELECT * FROM dbo.GET_TABLE_FROM_LIST(@rnnidnets, ',')
		END


		SELECT
				--RNN_ID,
				PR_NAME,		--RNN_ID_PERIOD,
				SYS_SHORT_NAME,	--RNN_ID_SYSTEM,
				RNN_DISTR_NUM,
				RNN_COMP_NUM,
				SH_SHORT_NAME,	--RNN_ID_HOST,
				SST_NAME,		--RNN_ID_TYPE,
				NULL AS TT_NAME,		--TT_ID
				RNN_DATE,
				RNN_DATE_ON,
				RNN_COMMENT,
				RNN_NUM_CLIENT,
				RNN_PSEDO_CLIENT,
				SNC_NET_COUNT	--RNN_ID_NET,

		FROM
				dbo.PeriodRegNewView	A											INNER JOIN
				#periods			B	ON	A.RNN_ID_PERIOD=B.period_id			INNER JOIN
				#systems			C	ON	A.RNN_ID_SYSTEM=C.system_id			INNER JOIN
				#subhosts			D	ON	A.RNN_ID_HOST=	D.subhost_id		INNER JOIN
				#systemtypes		E	ON	A.RNN_ID_TYPE=	E.system_type_id	INNER JOIN
				#netcounts			F	ON	A.RNN_ID_NET=	F.nc_id
		--		#cours				G	ON	A.REG_ID_COUR=	G.cour_id			--INNER JOIN

		WHERE
		/*
		--		RNN_ID_PERIOD		=ISNULL(@rnnidperiod,	RNN_ID_PERIOD)		and
		--		RNN_ID_SYSTEM		=ISNULL(@rnnidsystem,	RNN_ID_SYSTEM)		and
				RNN_DISTR_NUM		=ISNULL(@rnndistrnum,	RNN_DISTR_NUM)		and
		--		RNN_COMP_NUM		=ISNULL(@rnncompnum,	RNN_COMP_NUM)		and
		--		RNN_ID_HOST			=ISNULL(@rnnidhost,		RNN_ID_HOST)		and
		--		RNN_ID_TYPE			=ISNULL(@rnnidtype,		RNN_ID_TYPE)		and
				RNN_DATE     BETWEEN ISNULL(@beg_rnndate,	RNN_DATE)			and
									 ISNULL(@end_rnndate,	RNN_DATE)			and
				RNN_DATE_ON	 BETWEEN ISNULL(@beg_rnndateon,	RNN_DATE_ON)		and
									 ISNULL(@end_rnndateon,	RNN_DATE_ON)		and
		--		RNN_ID_NET			=ISNULL(@rnnnet,		RNN_ID_NET)			and
				RNN_NUM_CLIENT		=ISNULL(@rnnnumclient,	RNN_NUM_CLIENT)		and
				RNN_PSEDO_CLIENT LIKE ISNULL(@rnnpsedo,		RNN_PSEDO_CLIENT)	and
				RNN_COMMENT		LIKE ISNULL(@rnncomment,	RNN_COMMENT)
		*/
		-- 24.11.09. Денисов А.С. поменял все в хлам, ибо не работало
		(RNN_DISTR_NUM = @rnndistrnum OR @rnndistrnum IS NULL) AND
		--(RNN_ID_PERIOD = @rnnidperiod OR @rnnperiod IS NULL) AND
		--(RNN_ID_SYSTEM = @rnnidsystem OR @rnnidsystem IS NULL) AND
		--(RNN_COMP_NUM = @rnncompnum OR @rnncompnum IS NULL) AND
		--(RNN_ID_HOST = @rnnidhost OR @rnnidhost IS NULL) AND
		--(RNN_ID_TYPE = @rnnidtype OR @rnnidtype IS NULL) AND
		(RNN_DATE >= @beg_rnndate OR @beg_rnndate IS NULL) AND
		(RNN_DATE <= @end_rnndate OR @end_rnndate IS NULL) AND
		(RNN_DATE_ON >= @beg_rnndateon OR @beg_rnndateon IS NULL) AND
		(RNN_DATE_ON <= @end_rnndateon OR @end_rnndateon IS NULL) AND
		--(RNN_ID_NET = @rnnnet OR @rnnnet IS NULL) AND
		(RNN_NUM_CLIENT = @rnnnumclient OR @rnnnumclient IS NULL) AND
		(RNN_PSEDO_CLIENT LIKE @rnnpsedo OR @rnnpsedo IS NULL) AND
		(RNN_COMMENT LIKE @rnncomment OR @rnncomment IS NULL)

		IF OBJECT_ID('tempdb..#periods') IS NOT NULL
			DROP TABLE #periods
		IF OBJECT_ID('tempdb..#systems') IS NOT NULL
			DROP TABLE #systems
		IF OBJECT_ID('tempdb..#subhosts') IS NOT NULL
			DROP TABLE #subhosts
		IF OBJECT_ID('tempdb..#systemtypes') IS NOT NULL
			DROP TABLE #systemtypes
		IF OBJECT_ID('tempdb..#netcounts') IS NOT NULL
			DROP TABLE #netcounts

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PERIOD_REG_NEW_FILTER] TO rl_reg_node_r;
GO
