USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[START_KEY_USR_CHECK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[START_KEY_USR_CHECK]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Report].[START_KEY_USR_CHECK]
	@PARAM	NVARCHAR(MAX) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@CheckDate		SmallDateTime = '20220607',
		@MinDate		SmallDateTime = '20220101';

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
			[Start.key в папке К+|Содержимое]		= T.[UF_START_KEY_CONS_CONTENT],
			[Start.key в папке К+|Дата]				= T.[UF_START_KEY_CONS_DATE],
			[Start.key в рабочей папке|Содержимое]	= T.[UF_START_KEY_WORK_CONTENT],
			[Start.key в рабочей папке|Дата]		= T.[UF_START_KEY_WORK_DATE]
		FROM [USR].[USRActiveView] AS U
		INNER JOIN [USR].[USRFileTech] AS T ON T.UF_ID = U.UF_ID
		INNER JOIN [Reg].[RegNodeSearchView] AS R ON R.[DistrNumber] = U.[UD_DISTR] AND R.[CompNumber] = U.[UD_COMP] AND R.[HostID] = U.[UD_ID_HOST]
		LEFT JOIN [dbo].[ClientDistrView] AS D WITH(NOEXPAND) ON D.[HostID] = R.[HostID] AND D.[DISTR] = R.[DistrNumber] AND D.[COMP] = R.[CompNumber]
		LEFT JOIN [dbo].[ClientView] AS C WITH(NOEXPAND) ON C.[ClientID] = D.[ID_CLIENT]
		WHERE R.[NT_ID] IN (SELECT [NT_ID] FROM [Din].[NetTypeOffline]())
			AND R.[DS_REG] = 0
			AND U.[UD_ACTIVE] = 1
			--/*
			AND
			(
				T.[UF_START_KEY_CONS_DATE] IS NULL AND T.[UF_START_KEY_WORK_DATE] IS NULL
				OR
				T.[UF_START_KEY_CONS_DATE] < @CheckDate
				OR
				T.[UF_START_KEY_WORK_DATE] < @CheckDate
			)
			--*/
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
GRANT EXECUTE ON [Report].[START_KEY_USR_CHECK] TO rl_report;
GO
