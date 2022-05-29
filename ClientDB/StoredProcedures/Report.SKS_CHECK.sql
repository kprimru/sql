USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[SKS_CHECK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[SKS_CHECK]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[SKS_CHECK]
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

        SELECT
			[Рук-ль]				= IsNull(C.[ManagerName], R.[SubhostName]),
			[СИ]					= IsNull(C.[ServiceName], R.[SubhostName]),
			[Клиент]				= IsNull(C.[ClientFullName], R.[Comment]),
			[Осн.дистр|Номер]		= R.[DistrStr],
			[Осн.дистр|Тип]			= R.[SST_SHORT],
			[Осн.дистр|Сеть]		= R.[NT_SHORT],
			[Осн.дистр|Дата рег]	= R.[RegisterDate],
			[СКС.дистр|Номер]		= S.[DistrStr],
			[СКС.дистр|Примечание]	= S.[Comment],
			[СКС.дистр|Дата рег]	= S.[RegisterDate]
		FROM [Reg].[RegNodeSearchView]		AS R WITH(NOEXPAND)
		LEFT JOIN [dbo].[ClientDistrView]	AS D WITH(NOEXPAND) ON D.[HostID] = R.[HostID] AND D.[DISTR] = R.[DistrNumber] AND D.[COMP] = R.[CompNumber]
		LEFT JOIN [dbo].[ClientView]		AS C WITH(NOEXPAND) ON C.[ClientID] = D.[ID_CLIENT]
		OUTER APPLY
		(
			SELECT TOP (1)
				S.[DistrStr],
				S.[Comment],
				S.[RegisterDate]
			FROM [Reg].[RegNodeSearchView] AS S
			WHERE S.[Comment] LIKE 'ОС' + Cast(R.[DistrNumber] AS VarChar(100)) + ' %'
				AND S.[SystemBaseName] = 'SKS'
				AND S.[DS_REG] = 0
		) AS S
		-- TODO: именованные множества
		WHERE R.[NT_SHORT] IN ('ОВП', 'ОВК', 'ОВМ (ОД 1)', 'ОВМ (ОД 2)')
			AND R.[SST_SHORT] NOT IN ('ДСП', 'ОДД')
			AND R.[HostID] = 1
			AND R.[DS_REG] = 0

		UNION ALL

		SELECT
			IsNull(C.[ManagerName], R.[SubhostName]),
			IsNull(C.[ServiceName], R.[SubhostName]),
			IsNull(C.[ClientFullName], R.[Comment]),
			NULL,
			NULL,
			NULL,
			NULL,
			R.[DistrStr],
			R.[Comment],
			R.[RegisterDate]
		FROM [Reg].[RegNodeSearchView]		AS R WITH(NOEXPAND)
		LEFT JOIN [dbo].[ClientDistrView]	AS D WITH(NOEXPAND) ON D.[HostID] = R.[HostID] AND D.[DISTR] = R.[DistrNumber] AND D.[COMP] = R.[CompNumber]
		LEFT JOIN [dbo].[ClientView]		AS C WITH(NOEXPAND) ON C.[ClientID] = D.[ID_CLIENT]
		WHERE R.[SystemBaseName] = 'SKS'
			AND R.[DS_REG] = 0
			AND NOT EXISTS
				(
					SELECT *
					FROM [Reg].[RegNodeSearchView] AS S
					WHERE R.[Comment] LIKE 'ОС' + Cast(S.[DistrNumber] AS VarChar(100)) + ' %'
						AND S.[SystemBaseName] != 'SKS'
						AND S.[DS_REG] = 0
				)

		ORDER BY 1, 2, 3, 4;


		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
