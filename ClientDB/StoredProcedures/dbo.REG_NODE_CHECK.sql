USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[REG_NODE_CHECK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[REG_NODE_CHECK]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[REG_NODE_CHECK]
	@MANAGER		INT = NULL,
	@SERVICE		INT = NULL,
	@BASE			BIT = 1,
	@BASE_ON		BIT = 1,
	@REG			BIT = 1,
	@REG_ON			BIT = 1,
	@REG_SUBHOST	BIT = 1,
	@NET			BIT = 1,
	@STATUS			BIT = 1,
	@SYSTEM			BIT = 1
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

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		CREATE TABLE #res
			(
				ID_HOST		INT,
				DISTR		INT,
				COMP		TINYINT,
				DIS_STR		VARCHAR(50),
				ID_CLIENT	INT,
				TP			VARCHAR(64),
				BASE_VALUE	VARCHAR(100),
				REG_VALUE	VARCHAR(100),
				LAST_REG	SMALLDATETIME,
				COMPLECT	VARCHAR(50),
				COMMENT		VARCHAR(100)
			)

		IF @BASE = 1
			INSERT INTO #res(ID_HOST, DISTR, COMP, DIS_STR, ID_CLIENT, TP, BASE_VALUE, REG_VALUE, LAST_REG, COMPLECT, COMMENT)
				SELECT a.HostID, DISTR, COMP, DistrStr, ID_CLIENT, 'Система не найдена в РЦ', '', '', NULL, NULL, NULL
				FROM
					dbo.ClientDistrView a WITH(NOEXPAND)
					INNER JOIN dbo.SystemTable b ON a.SystemID = b.SystemID
					INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = a.ID_CLIENT
				WHERE b.SystemRic = 20
					AND (@BASE_ON = 0 OR @BASE_ON = 1 AND DS_REG = 0)
					AND NOT EXISTS
					(
						SELECT *
						FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
						WHERE a.DISTR = z.DistrNumber
							AND a.COMP = z.CompNumber
							AND a.HostID = z.HostID
					)

		IF @REG = 1
			INSERT INTO #res(ID_HOST, DISTR, COMP, DIS_STR, ID_CLIENT, TP, BASE_VALUE, REG_VALUE, LAST_REG, COMPLECT, COMMENT)
				SELECT
					a.HostID, DistrNumber, CompNumber, DistrStr, ID_CLIENT, 'Система не найдена в базе', '', '', RegisterDate, Complect, Comment
				FROM
					Reg.RegNodeSearchView a WITH(NOEXPAND)
					INNER JOIN dbo.DistrStatus b ON a.DS_ID = b.DS_ID
					OUTER APPLY
						(
							SELECT TOP 1 ID_CLIENT
							FROM
								Reg.RegNodeSearchView c WITH(NOEXPAND)
								INNER JOIN dbo.ClientDistrView d WITH(NOEXPAND) ON d.DISTR = c.DistrNumber
																				AND d.COMP = c.CompNumber
																				AND d.HostID = c.HostID
							WHERE c.Complect = a.Complect
							ORDER BY d.SystemOrder
						) AS o_O
				WHERE SST_SHORT NOT IN ('АДМ', 'ДИУ', 'ОДД', 'ДСП')
					AND (@REG_ON = 0 OR @REG_ON = 1 AND b.DS_REG = 0)
					AND (@REG_SUBHOST = 1 AND SubhostName = '' OR @REG_SUBHOST = 0)
					AND NOT EXISTS
					(
						SELECT *
						FROM dbo.ClientDistrView z WITH(NOEXPAND)
						WHERE z.DISTR = a.DistrNumber
							AND z.COMP = a.CompNumber
							AND z.HostID = a.HostID
					)

		IF @NET = 1
			INSERT INTO #res(ID_HOST, DISTR, COMP, DIS_STR, ID_CLIENT, TP, BASE_VALUE, REG_VALUE, LAST_REG, COMPLECT, COMMENT)
				SELECT a.HostID, DISTR, COMP, a.DistrStr, ID_CLIENT, 'Не совпадает тип сети', a.DistrTypeName, b.NT_SHORT, RegisterDate, Complect, Comment
				FROM
					dbo.ClientDistrView a WITH(NOEXPAND)
					INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber
																	AND a.COMP = b.CompNumber
																	AND a.HostID = b.HostID
					INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = a.ID_CLIENT
					INNER JOIN Din.NetType d ON d.NT_ID = b.NT_ID
				WHERE d.NT_ID_MASTER <> a.DistrTypeID

		IF @STATUS = 1
			INSERT INTO #res(ID_HOST, DISTR, COMP, DIS_STR, ID_CLIENT, TP, BASE_VALUE, REG_VALUE, LAST_REG, COMPLECT, COMMENT)
				SELECT a.HostID, DISTR, COMP, a.DistrStr, ID_CLIENT, 'Не совпадает статус', a.DS_NAME, d.DS_NAME, b.RegisterDate, Complect, Comment
				FROM
					dbo.ClientDistrView a WITH(NOEXPAND)
					INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber
																	AND a.COMP = b.CompNumber
																	AND a.HostID = b.HostID
					INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = a.ID_CLIENT
					INNER JOIN dbo.DistrStatus d ON d.DS_ID = b.DS_ID
				WHERE a.DS_ID <> b.DS_ID

		IF @SYSTEM = 1
			INSERT INTO #res(ID_HOST, DISTR, COMP, DIS_STR, ID_CLIENT, TP, BASE_VALUE, REG_VALUE, LAST_REG, COMPLECT, COMMENT)
				SELECT a.HostID, DISTR, COMP, a.DistrStr, ID_CLIENT, 'Система заменена', a.SystemShortName, b.SystemShortName, b.RegisterDate, Complect, Comment
				FROM
					dbo.ClientDistrView a WITH(NOEXPAND)
					INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber
																	AND a.COMP = b.CompNumber
																	AND a.HostID = b.HostID
					INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = a.ID_CLIENT
				WHERE a.SystemID <> b.SystemID

		SELECT
			ClientID, ISNULL(ClientFullName, Comment) AS ClientName, DIS_STR,
			ManagerName, ServiceName, TP, BASE_VALUE, REG_VALUE, LAST_REG, COMPLECT,
			ServiceName + ' (' + ManagerName + ')' AS ServiceStr,
			ISNULL(ClientFullName, Complect + '/' + Complect) AS ClientComplect
		FROM
			#res a
			LEFT OUTER JOIN dbo.ClientView b WITH(NOEXPAND) ON b.ClientID = a.ID_CLIENT
		WHERE (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
		ORDER BY TP, ManagerName, ServiceName, ClientFullName, DIS_STR


		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REG_NODE_CHECK] TO rl_reg_node_audit;
GO
