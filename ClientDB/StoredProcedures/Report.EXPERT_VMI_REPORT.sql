USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[EXPERT_VMI_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[EXPERT_VMI_REPORT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Report].[EXPERT_VMI_REPORT]
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

		SELECT MON AS [Месяц], ManagerName AS [Рук-ль], ServiceName AS [СИ], ClientFullName AS [Клиент], b.DistrStr AS [Дистрибутив], Comment AS [Название в РЦ]
		FROM
			(
				SELECT
					MON, HostID,
					CONVERT(INT,
									CASE
										WHEN CHARINDEX('_', REVERSE(DIS_S)) > 3 THEN
												RIGHT(DIS_S, LEN(DIS_S) - CHARINDEX('_', DIS_S))
										ELSE LEFT(RIGHT(DIS_S, LEN(DIS_S) - CHARINDEX('_', DIS_S)), CHARINDEX('_', RIGHT(DIS_S, LEN(DIS_S) - CHARINDEX('_', DIS_S))) - 1)
									END) AS DISTR,
						CASE
							WHEN CHARINDEX('_', REVERSE(DIS_S)) > 3 THEN 1
							ELSE CONVERT(INT, REVERSE(LEFT(REVERSE(DIS_S), CHARINDEX('_', REVERSE(DIS_S)) - 1)))
						END AS COMP
				FROM
					(
						SELECT DISTINCT MON, Item AS DIS_S
						FROM
							dbo.ExpertVMI
							CROSS APPLY (SELECT Item FROM dbo.GET_STRING_TABLE_FROM_LIST(DISTR, ',')) AS o_O
					) AS a
					INNER JOIN dbo.SystemTable ON CONVERT(INT, LEFT(DIS_S, CHARINDEX('_', DIS_S) - 1)) = SystemNumber
			) AS a
			INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.HostID = b.HostID AND a.DISTR = b.DistrNumber AND a.COMP = b.CompNumber
			LEFT OUTER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON a.HostID = c.HostID AND a.DISTR = c.DISTR AND a.COMP = c.COMP
			LEFT OUTER JOIN dbo.ClientView d WITH(NOEXPAND) ON d.ClientID = c.ID_CLIENT
		ORDER BY MON, SubhostName, ManagerName, ServiceName, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[EXPERT_VMI_REPORT] TO rl_report;
GO
