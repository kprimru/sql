USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[START_KEY_CHECK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[START_KEY_CHECK]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Report].[START_KEY_CHECK]
	@PARAM	NVARCHAR(MAX) = NULL
WITH EXECUTE AS OWNER
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

        SELECT
			[Рук-ль]								= IsNull(C.[ManagerName], R.[SubhostName]),
			[СИ]									= IsNull(C.[ServiceName], R.[SubhostName]),
			[Клиент]								= IsNull(C.[ClientFullName], R.[Comment]),
			[Дистр]									= R.[DistrStr],
			[Сеть]									= R.[NT_SHORT],
			[Тип]									= R.[SST_SHORT],
			[Дата время последней записи в логе]	= Convert(VarChar(20), L.[Date], 104) + ' ' + Convert(VarChar(20), L.[Time], 108),
			[Наличие Start.key]						= CASE WHEN L.[Raw] IS NULL THEN 'Неизвестно' WHEN L.[Raw] LIKE '%START.KEY: нет параметров%' THEN 'Нет' ELSE 'Да' END,
			[Запись в логе]							= L.[Raw]
		FROM [IPLogs].[dbo].[USRFiles] AS U
		INNER JOIN [IPLogs].[dbo].[ConsErr] AS E ON U.[UF_ID] = E.[ID_USR]
		INNER JOIN [dbo].[SystemTable] AS S ON S.[SystemNumber] = U.[UF_SYS]
		INNER JOIN [Reg].[RegNodeSearchView] AS R WITH(NOEXPAND) ON R.[HostID] = S.[HostID] AND R.[DistrNumber] = U.[UF_DISTR] AND R.[CompNumber] = U.[UF_COMP]
		LEFT JOIN [dbo].[ClientDistrView] AS D WITH(NOEXPAND) ON D.[HostID] = R.[HostID] AND D.[DISTR] = R.[DistrNumber] AND D.[COMP] = R.[CompNumber]
		LEFT JOIN [dbo].[ClientView] AS C WITH(NOEXPAND) ON C.[ClientID] = D.[ID_CLIENT]
		OUTER APPLY
		(
			SELECT TOP (1)
				L.[Date],
				L.[Time],
				L.[Raw]
			FROM
			(
				SELECT
					[Date],
					[Time],
					[Raw]
				FROM
				(
					SELECT
						[Date]	= Convert(Date, Left(v.[value], 10), 104),
						[Time]	= Convert(Time, SubString(v.[value], 12, 12), 21),
						[Raw]	= Replace(Replace(CASE WHEN Len(v.[value]) > 24 THEN Right(V.[value], Len(v.[value]) - 24) ELSE NULL END, Char(10), ''), Char(13), '')
					FROM string_split(Cast(E.[INET_LOG_DATA] AS NVarChar(Max)), Char(10)) AS V
					WHERE v.[value] != ''
				) AS L
				WHERE [Raw] != '--------------------------------------------------------------------------------'
			) AS L
			WHERE [Raw] LIKE '%START.KEY:%'
			ORDER BY L.[Date] DESC, L.[Time] DESC
		) AS L
		WHERE R.SST_SHORT NOT IN ('ДИУ', 'АДМ', 'ДСП')
		ORDER BY
			R.[SubhostName],
			C.[ManagerName],
			C.[ServiceName],
			C.[ClientFullName];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[START_KEY_CHECK] TO rl_report;
GO
