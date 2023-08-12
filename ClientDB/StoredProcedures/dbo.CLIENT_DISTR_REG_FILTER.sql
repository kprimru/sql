USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DISTR_REG_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DISTR_REG_FILTER]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_DISTR_REG_FILTER]
	@MANAGER	INT
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

		IF OBJECT_ID('tempdb..#oper') IS NOT NULL
			DROP TABLE #oper

		SELECT DISTINCT RPR_DATE, RPR_ID_HOST, RPR_DISTR, RPR_COMP, RPR_OPER
		INTO #oper
		FROM
			dbo.RegProtocol
		WHERE RPR_OPER IN ('НОВАЯ', 'Изм. парам.', 'Включение')
			AND RPR_DATE >= DATEADD(MONTH, -2, GETDATE())



		SELECT ClientID, ClientFullName, ManagerName, ServiceName, DistrStr, RPR_OPER, dbo.DateOf(RPR_DATE) AS DATE, RPR_NOTE
		FROM
			(
				SELECT ClientID, ClientFullName, ManagerName, ServiceName, DistrStr, RPR_OPER, RPR_DATE, '' AS RPR_NOTE, ManagerID
				FROM
					#oper a
					INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON RPR_ID_HOST = HostID AND RPR_DISTR = DISTR AND RPR_COMP = COMP
					INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON ClientID = ID_CLIENT
				WHERE RPR_OPER = 'Включение'

				UNION ALL

				SELECT DISTINCT ClientID, ClientFullName, ManagerName, ServiceName, z.DistrStr, RPR_OPER, RPR_DATE, '' AS RPR_NOTE, ManagerID
				FROM
					#oper a
					INNER JOIN Reg.RegNodeSearchView z WITH(NOEXPAND) ON a.RPR_ID_HOST = z.HostID AND RPR_DISTR = z.DistrNumber AND RPR_COMP = z.CompNumber
					INNER JOIN Reg.RegNodeSearchView y WITH(NOEXPAND) ON z.Complect = y.Complect
					INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON b.HostID = y.HostID AND b.DISTR = y.DistrNumber AND b.COMP = y.CompNumber
					INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON ClientID = ID_CLIENT
				WHERE RPR_OPER = 'НОВАЯ'

				UNION ALL

				SELECT ClientID, ClientFullName, ManagerName, ServiceName, DistrStr, RPR_OPER, RPR_DATE,
					'c ' +
					ISNULL((
						SELECT TOP 1 z.SystemShortName + ' ' + z.NT_SHORT
						FROM
							Reg.RegHistoryView z WITH(NOEXPAND)
							INNER JOIN Reg.RegDistr y ON z.ID_DISTR = y.ID
						WHERE y.ID_HOST = a.RPR_ID_HOST AND y.DISTR = a.RPR_DISTR AND y.COMP = a.RPR_COMP
							AND DATEADD(MINUTE, 1, z.DATE) < a.RPR_DATE
						ORDER BY z.DATE DESC
					), '')	+ ' на ' +
					ISNULL((
						SELECT TOP 1 z.SystemShortName + ' ' + z.NT_SHORT
						FROM
							Reg.RegHistoryView z WITH(NOEXPAND)
							INNER JOIN Reg.RegDistr y ON z.ID_DISTR = y.ID
						WHERE y.ID_HOST = a.RPR_ID_HOST AND y.DISTR = a.RPR_DISTR AND y.COMP = a.RPR_COMP
							AND DATEADD(MINUTE, 1, z.DATE) > a.RPR_DATE
						ORDER BY z.DATE
					), ''), ManagerID
				FROM
					#oper a
					INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON RPR_ID_HOST = HostID AND RPR_DISTR = DISTR AND RPR_COMP = COMP
					INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON ClientID = ID_CLIENT
				WHERE RPR_OPER = 'Изм. парам.'
			) AS o_O
		WHERE ManagerID = @MANAGER OR @MANAGER IS NULL
		ORDER BY DATE DESC, ManagerName, ServiceName, ClientFullName

		IF OBJECT_ID('tempdb..#oper') IS NOT NULL
			DROP TABLE #oper

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_REG_FILTER] TO rl_distr_reg_filter;
GO
