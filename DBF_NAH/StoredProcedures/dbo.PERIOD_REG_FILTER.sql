USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Àâòîð:
Îïèñàíèå:
*/

ALTER PROCEDURE [dbo].[PERIOD_REG_FILTER]
	@regidperiods		VARCHAR(MAX),
	@regidsystems		VARCHAR(MAX),
	@regdistrnum		INT,
	@regidhosts			VARCHAR(MAX),
	@regidtypes			VARCHAR(MAX),
	@regidnets			VARCHAR(MAX),
	@beg_regdate		SMALLDATETIME,
	@end_regdate		SMALLDATETIME,
	@regcomment			VARCHAR(MAX),
	@regnumclient		INT,
	@regpsedo			VARCHAR(MAX),
	@regidcours			VARCHAR(MAX),
	@regcomplect		VARCHAR(50),
	@regidstatuses		VARCHAR(MAX),
	@regidtechtype		VARCHAR(MAX) = null
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
		--ÏÅÐÈÎÄÛ--
		-----------
		IF OBJECT_ID('tempdb..#periods') IS NOT NULL
			DROP TABLE #periods

		CREATE TABLE #periods ( period_id INT NOT NULL )
		IF @regidperiods IS NULL
			BEGIN
				INSERT INTO #periods
					SELECT PR_ID FROM dbo.PeriodTable
			END
		ELSE
			BEGIN
				INSERT INTO #periods
					SELECT * FROM dbo.GET_TABLE_FROM_LIST(@regidperiods, ',')
			END

		-----------
		--ÑÈÑÒÅÌÛ--
		-----------
		IF OBJECT_ID('tempdb..#systems') IS NOT NULL
			DROP TABLE #systems
		CREATE TABLE #systems ( system_id INT NOT NULL )
		IF @regidsystems IS NULL
			BEGIN
				INSERT INTO #systems
					SELECT SYS_ID FROM dbo.SystemTable
			END
		ELSE
			BEGIN
				INSERT INTO #systems
					SELECT * FROM dbo.GET_TABLE_FROM_LIST(@regidsystems, ',')
			END

		------------
		--ÏÎÄÕÎÑÒÛ--
		------------
		IF OBJECT_ID('tempdb..#subhosts') IS NOT NULL
			DROP TABLE #subhosts
		CREATE TABLE #subhosts ( subhost_id INT NOT NULL )
		IF @regidhosts IS NULL
			BEGIN
				INSERT INTO #subhosts
					SELECT SH_ID FROM dbo.SubhostTable
			END
		ELSE
			BEGIN
				INSERT INTO #subhosts
					SELECT * FROM dbo.GET_TABLE_FROM_LIST(@regidhosts, ',')
			END

		---------------
		--ÒÈÏÛ ÑÈÑÒÅÌ--
		---------------
		IF OBJECT_ID('tempdb..#systemtypes') IS NOT NULL
			DROP TABLE #systemtypes
		CREATE TABLE #systemtypes ( system_type_id INT NOT NULL )
		IF @regidtypes IS NULL
			BEGIN
				INSERT INTO #systemtypes
					SELECT SST_ID FROM dbo.SystemTypeTable
			END
		ELSE
			BEGIN
				INSERT INTO #systemtypes
					SELECT * FROM dbo.GET_TABLE_FROM_LIST(@regidtypes, ',')
			END

		-------------
		--NET COUNT--
		-------------
		IF OBJECT_ID('tempdb..#netcounts') IS NOT NULL
			DROP TABLE #netcounts
		CREATE TABLE #netcounts ( nc_id INT NOT NULL )
		IF @regidnets IS NULL
			BEGIN
				INSERT INTO #netcounts
					SELECT SNC_ID FROM dbo.SystemNetCountTable
			END
		ELSE
			BEGIN
				INSERT INTO #netcounts
					SELECT * FROM dbo.GET_TABLE_FROM_LIST(@regidnets, ',')
			END

		-----------
		--ÊÓÐÜÅÐÛ--
		-----------
		IF OBJECT_ID('tempdb..#cours') IS NOT NULL
			DROP TABLE #cours
		CREATE TABLE #cours ( cour_id INT NOT NULL )
		IF @regidcours IS NULL
			BEGIN
				INSERT INTO #cours
					SELECT COUR_ID FROM dbo.CourierTable
			END
		ELSE
			BEGIN
				INSERT INTO #cours
					SELECT * FROM dbo.GET_TABLE_FROM_LIST(@regidcours, ',')
			END

		------------------------
		--ÑÒÀÒÓÑÛ ÎÁÑËÓÆÈÂÀÍÈß--
		------------------------
		IF OBJECT_ID('tempdb..#statuses') IS NOT NULL
			DROP TABLE #statuses
		CREATE TABLE #statuses ( status_id INT NOT NULL )
		IF @regidstatuses IS NULL
			BEGIN
				INSERT INTO #statuses
					SELECT PR_ID FROM dbo.PeriodTable
			END
		ELSE
			BEGIN
				INSERT INTO #statuses
					SELECT * FROM dbo.GET_TABLE_FROM_LIST(@regidstatuses, ',')
			END

		SELECT
			--REG_ID,
			PR_DATE,		--REG_ID_PERIOD,
			SYS_SHORT_NAME,	--REG_ID_SYSTEM,
			REG_DISTR_NUM,
			REG_COMP_NUM,
			SH_SHORT_NAME,	--REG_ID_HOST,
			SST_NAME,		--REG_ID_TYPE,
			NULL AS TT_NAME,		--REG_ID_TECH_TYPE
			DS_NAME,		--REG_ID_STATUS,	--REG_STATUS,
			REG_DATE,
			REG_COMMENT,
			REG_NUM_CLIENT,
			REG_PSEDO_CLIENT,
			COUR_NAME,		--REG_ID_COUR,
			SNC_NET_COUNT,	--REG_ID_NET,
			REG_COMPLECT

		FROM
			dbo.PeriodRegView	A										INNER JOIN
			#periods		B	ON	A.REG_ID_PERIOD=B.period_id			INNER JOIN
			#systems		C	ON	A.REG_ID_SYSTEM=C.system_id			INNER JOIN
			#subhosts		D	ON	A.REG_ID_HOST =	D.subhost_id		INNER JOIN
			#systemtypes	E	ON	A.REG_ID_TYPE =	E.system_type_id	INNER JOIN
			#netcounts		F	ON	A.REG_ID_NET =	F.nc_id				LEFT  JOIN
			#cours			G	ON	A.REG_ID_COUR =	G.cour_id			INNER JOIN
			#statuses		H	ON	A.REG_ID_STATUS=H.status_id

		WHERE
			/*
	--		REG_ID_PERIOD	=ISNULL(@regidperiods,	REG_ID_PERIOD)	and
	--		REG_ID_SYSTEM	=ISNULL(@regidsystems,	REG_ID_SYSTEM)	and
			REG_DISTR_NUM	=ISNULL(@regdistrnum,	REG_DISTR_NUM)	and
	----		REG_COMP_NUM	=ISNULL(@regcompnum,	REG_COMP_NUM)	and
	--		REG_ID_HOST		=ISNULL(@regidhosts,		REG_ID_HOST)	and
	--		REG_ID_TYPE		=ISNULL(@regidtypes,		REG_ID_TYPE)	and
	--		REG_ID_NET		=ISNULL(@regidnet,		REG_ID_NET)		and
	----		REG_STATUS		=ISNULL(@regstatus,		REG_STATUS)		and
			REG_DATE BETWEEN ISNULL(@beg_regdate,	REG_DATE)	and
							 ISNULL(@end_regdate,	REG_DATE)		and
			REG_COMMENT LIKE ISNULL(@regcomment,	REG_COMMENT)	and
			(REG_NUM_CLIENT	=ISNULL(@regnumclient,	REG_NUM_CLIENT)
							OR (REG_NUM_CLIENT IS NULL AND @regnumclient is NUll))	and
			(REG_PSEDO_CLIENT LIKE ISNULL(@regpsedo,	REG_PSEDO_CLIENT)
							OR (REG_PSEDO_CLIENT IS NULL AND @regpsedo is NUll))	and
	--		REG_ID_COUR		=ISNULL(@regidcours,		REG_ID_COUR)
			(REG_COMPLECT	=ISNULL(@regcomplect,	REG_COMPLECT)
							OR (REG_COMPLECT IS NULL AND @regcomplect is NUll))
			*/
			(REG_DISTR_NUM = @regdistrnum OR @regdistrnum IS NULL) AND
			(REG_DATE >= @beg_regdate OR @beg_regdate IS NULL) AND
			(REG_DATE <= @end_regdate OR @end_regdate IS NULL) AND
			(REG_COMMENT LIKE @regcomment OR @regcomment IS NULL) AND
			(REG_NUM_CLIENT = @regnumclient OR @regnumclient IS NULL) AND 
			(REG_PSEDO_CLIENT LIKE @regpsedo OR @regpsedo IS NULL) AND
			(REG_COMPLECT = @regcomplect OR @regcomplect IS NULL) 
		ORDER BY PR_DATE DESC, SYS_ORDER DESC, REG_DISTR_NUM

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
		IF OBJECT_ID('tempdb..#cours') IS NOT NULL
			DROP TABLE #cours
		IF OBJECT_ID('tempdb..#statuses') IS NOT NULL
			DROP TABLE #statuses

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PERIOD_REG_FILTER] TO rl_reg_node_r;
GO