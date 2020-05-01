USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_CALC_REPORT]
	@MANAGER	INT,
	@SERVICE	INT,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@UNCALC		BIT
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

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		CREATE TABLE #distr
			(
				ID		INT IDENTITY(1, 1) PRIMARY KEY,
				CLAIM	DATETIME,
				DIS_STR	NVARCHAR(128),
				SYS_REG	NVARCHAR(64),
				DISTR	INT,
				COMP	TINYINT,
				MON		SMALLDATETIME,
				CALC_NOTE	NVARCHAR(256),
				MANAGER	NVARCHAR(128),
				SERVICE	NVARCHAR(128),
				CLIENT	NVARCHAR(512),
				ClientID	INT
			)

		INSERT INTO #distr(CLAIM, DIS_STR, SYS_REG, DISTR, COMP, MON, CALC_NOTE, MANAGER, SERVICE, CLIENT, ClientID)
			SELECT
				CLAIM, dbo.DistrString(d.SystemShortName, c.DISTR, c.COMP),
				SYS_REG, c.DISTR, c.COMP, c.MON, c.CALC_NOTE, f.ManagerName, f.ServiceName, f.ClientFullName, ClientID
			FROM
				(
					SELECT SYS_REG, DISTR, COMP, MON, b.CALC_NOTE, MAX(DATE) AS CLAIM
					FROM
						dbo.ActCalc a
						INNER JOIN dbo.ActCalcDetail b ON a.ID = b.ID_MASTER
					WHERE (a.DATE >= @BEGIN OR @BEGIN IS NULL)
						AND (DATE < @END OR @END IS NULL)
					GROUP BY SYS_REG, DISTR, COMP, MON, b.CALC_NOTE
				) AS c
				INNER JOIN dbo.SystemTable d ON d.SystemBaseName = c.SYS_REG
				INNER JOIN dbo.ClientDistrView e WITH(NOEXPAND) ON e.HostID = d.HostID AND e.DISTR = c.DISTR AND e.COMP = c.COMP
				INNER JOIN dbo.ClientView f WITH(NOEXPAND) ON f.ClientID = e.ID_CLIENT
			WHERE (f.ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (f.ServiceID = @SERVICE OR @SERVICE IS NULL)
			ORDER BY ManagerName, ServiceName, ClientFullName, MON, d.SystemOrder, c.DISTR, c.COMP

		SELECT a.CLIENT, a.MANAGER, a.SERVICE, DIS_STR, MON, CASE WHEN b.DIS_NUM IS NULL THEN 'Не расчитан' ELSE 'Расчитан' END AS STAT, ClientID
		FROM
			#distr a
			LEFT OUTER JOIN dbo.DBFActView b ON a.SYS_REG = b.SYS_REG_NAME AND a.DISTR = b.DIS_NUM AND a.COMP = b.DIS_COMP_NUM AND a.MON = b.PR_DATE
		WHERE @UNCALC = 1 AND b.DIS_NUM IS NULL OR @UNCALC <> 1
		ORDER BY ID

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[ACT_CALC_REPORT] TO rl_act_report;
GO