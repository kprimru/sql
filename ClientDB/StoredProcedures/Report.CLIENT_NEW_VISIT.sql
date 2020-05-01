USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[CLIENT_NEW_VISIT]
	@PARAM	NVARCHAR(MAX) = NULL
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
				DATE	SMALLDATETIME,
				ID_HOST	SMALLINT,
				DISTR	INT,
				COMP	TINYINT
			)

			INSERT INTO #distr(ID_HOST, DISTR, COMP, DATE)
				SELECT RPR_ID_HOST, RPR_DISTR, RPR_COMP, dbo.DateOf(RPR_DATE)
				FROM
					dbo.RegProtocol
					INNER JOIN dbo.Hosts ON RPR_ID_HOST = HostID
				WHERE RPR_OPER IN ('Новая')
					AND HostReg = 'LAW'
		DELETE
		FROM #distr
		WHERE EXISTS
			(
				SELECT *
				FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
				INNER JOIN Din.SystemType c ON c.SST_ID = a.SST_ID
				WHERE DistrNumber = DISTR AND CompNumber = COMP AND HostID = ID_HOST AND SST_WEIGHT = 0
			)

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		SELECT
			DATE,
			ManagerName, ServiceName, ClientID, ClientFullName, DistrStr, DistrTypeName,
			(
				SELECT TOP (1) WEIGHT
				FROM dbo.WeightView W WITH(NOEXPAND)
				INNER JOIN Reg.RegNodeSearchView R WITH(NOEXPAND) ON W.SystemID = R.SystemID
																	AND W.NT_ID = R.NT_ID
																	AND W.SST_ID = R.SST_ID
				WHERE R.DistrNumber = b.DISTR AND R.CompNumber = b.COMP AND R.HostId = b.HostId
					AND W.DATE <= a.DATE
				ORDER BY a.DATE DESC
			) AS WEIGHT
		INTO #result
		FROM
			#distr a
			INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.DISTR = b.DISTR AND a.COMP = b.COMP AND a.ID_HOST = b.HostID
			INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
		ORDER BY DATE DESC, ManagerName, ServiceName, SystemOrder

		SELECT
			ManagerName AS [Руководитель], ServiceName AS [СИ], ClientFullName AS [Клиент], DistrStr AS [Дистрибутив], DistrTypeName AS [Сеть],
			DATE AS [Дата подключения], WEIGHT AS [Вес],
			CONVERT(BIT, CASE WHEN NOT EXISTS
				(
					SELECT ID
					FROM dbo.ClientContact z
					WHERE ID_CLIENT = ClientID
						AND STATUS = 1
						AND z.DATE >= a.DATE

					UNION ALL

					SELECT ID
					FROM Task.Tasks z
					WHERE ID_CLIENT = ClientID
						AND STATUS = 1
						AND z.DATE >= a.DATE
				) THEN 0 ELSE 1 END) AS [Наличие записи о визите],
			REVERSE(STUFF(REVERSE((
				SELECT CONVERT(NVARCHAR(32), DATE, 104) + CHAR(10) + PERSONAL + CHAR(10) + NOTE + CHAR(10) + CHAR(10) + PROBLEM + CHAR(10)+CHAR(10)+CHAR(10)
				FROM
					(
						SELECT DATE, PERSONAL, NOTE, PROBLEM
						FROM
							dbo.ClientContact z
						WHERE ID_CLIENT = ClientID
							AND STATUS = 1
							AND z.DATE >= a.DATE

						UNION ALL

						SELECT DATE, SENDER, NOTE, ''
						FROM Task.Tasks z
						WHERE ID_CLIENT = ClientID
							AND STATUS = 1
							AND z.DATE >= a.DATE
					) AS z
				ORDER BY z.DATE DESC FOR XML PATH('')
			)), 1, 3, '')) AS [Запись о визите]
			/*
			CONVERT(BIT, CASE WHEN NOT EXISTS
				(
					SELECT *
					FROM Task.Tasks z
					WHERE ID_CLIENT = ClientID
						AND STATUS = 1
						AND z.DATE >= a.DATE
				) THEN 0 ELSE 1 END) AS [Наличие записи о визите],
			REVERSE(STUFF(REVERSE((
				SELECT CONVERT(NVARCHAR(32), DATE, 104) + CHAR(10) + SENDER + CHAR(10) + SHORT + CHAR(10) + NOTE + CHAR(10)+CHAR(10)+CHAR(10)
				FROM Task.Tasks z
				WHERE ID_CLIENT = ClientID
					AND STATUS = 1
					AND z.DATE >= a.DATE
				ORDER BY z.DATE DESC FOR XML PATH('')
			)), 1, 3, '')) AS [Запись о визите]
			*/
		FROM #result a
		WHERE DATE >= DATEADD(YEAR, -1, GETDATE())
		ORDER BY DATE DESC, ManagerName, ServiceName


		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Report].[CLIENT_NEW_VISIT] TO rl_report;
GO