USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_QUALITY_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_QUALITY_REPORT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_QUALITY_REPORT]
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
			C.[ClientID],
			C.[ClientFullName],
			MD.*,
			CD.[OnlineType],
			CASE WHEN DL.[IsLong] = 1 THEN 'ДСЦ' ELSE 'КСЦ' END AS [LognService],
			CO.[ContractTypes],
			CON.*,
			--[ContractQuality] = '',
			[BuhQuality] = W.[ToxicWords]
		FROM dbo.ClientTable AS C
		LEFT JOIN dbo.PayTypeTable AS P ON P.PayTypeID = C.PayTypeID
		OUTER APPLY
		(
			SELECT TOP (1)
				MD.[DistrStr], MD.[DistrTypeName], MD.[SystemTypeName]
			FROM [dbo].[ClientDistrView] AS MD
			WHERE MD.[ID_CLIENT] = C.[ClientID]
				AND MD.[DS_REG] = 0
			ORDER BY MD.[SystemOrder], MD.[DISTR], MD.[COMP]
		) AS MD
		OUTER APPLY
		(
			SELECT [ContractTypes] = String_Agg(CO.[ContractTypeName], ',')
			FROM
			(
				SELECT DISTINCT CD.[ContractTypeName]
				FROM [Contract].[ClientContracts] AS CC
				INNER JOIN [Contract].[Contract] AS CO ON CO.[ID] = CC.[Contract_Id]
				CROSS APPLY
				(
					SELECT TOP (1) CT.[ContractTypeName]
					FROM [Contract].[ClientContractsDetails] AS CD
					INNER JOIN [dbo].[ContractTypeTable] AS CT ON CT.[ContractTypeID] = CD.[Type_Id]
					WHERE CD.[Contract_Id] = CO.[ID]
					ORDER BY CD.[DATE] DESC
				) AS CD
				WHERE CC.[Client_Id] = C.[ClientID]
					AND CO.[DateFrom] <= GetDate()
					AND (CO.[DateTo] IS NULL OR Co.[DateTo] > GetDate())
			) AS CO
		) AS CO
		OUTER APPLY
		(
			SELECT TOP (1) CO.*
			FROM
			(
				SELECT CO.[NUM_S], CO.[DATE], 'Договор' AS [Type]
				FROM [Contract].[ClientContracts] AS CC
				INNER JOIN [Contract].[Contract] AS CO ON CO.[ID] = CC.[Contract_Id]
				WHERE CC.[Client_Id] = C.[ClientID]
					AND CO.[DateFrom] <= GetDate()
					AND (CO.[DateTo] IS NULL OR Co.[DateTo] > GetDate())
				UNION ALL
				SELECT Cast(CA.[NUM] AS VarChar(100)), CA.[SignDate], 'Доп.соглашение' AS [Type]
				FROM [Contract].[ClientContracts] AS CC
				INNER JOIN [Contract].[Contract] AS CO ON CO.[ID] = CC.[Contract_Id]
				INNER JOIN [Contract].[Additional] AS CA ON CA.[ID_CONTRACT] = CC.[Contract_Id]
				WHERE CC.[Client_Id] = C.[ClientID]
					AND CO.[DateFrom] <= GetDate()
					AND (CO.[DateTo] IS NULL OR Co.[DateTo] > GetDate())
			) AS CO
			ORDER BY CO.[DATE] DESC
		) AS CON
		OUTER APPLY
		(
			SELECT
				[OnlineCount],
				[OfflineCount],
				[OnlineType] =
					CASE
						WHEN [OnlineCount] > 0 AND [OfflineCount] > 0 THEN 'ОГС'
						WHEN [OnlineCount] > 0 AND [OfflineCount] = 0 THEN 'чОВ'
						WHEN [OnlineCount] = 0 AND [OfflineCount] > 0 THEN 'ОГС'
						WHEN [OnlineCount] = 0 AND [OfflineCount] = 0 THEN 'Отсутствуют дистрибутивы'
						ELSE 'Ошибка!'
					END
			FROM
			(
				SELECT
					[OnlineCount] = Sum(CASE WHEN O.[IsOnline] = 1 THEN 1 ELSE 0 END),
					[OfflineCount] = Sum(CASE WHEN O.[IsOnline] = 0 THEN 1 ELSE 0 END)
				FROM [dbo].[ClientDistrView] AS CD
				OUTER APPLY
				(
					SELECT
						[IsOnline] =
							CASE
								WHEN	CD.SystemBaseName != 'SKS'
									AND CD.DistrTypeBaseCheck = 1
									AND CD.SystemBaseCheck = 1 THEN 0
								ELSE 1
							END
				) AS O
				WHERE CD.[ID_CLIENT] = C.[ClientID]
					AND CD.[DS_REG] = 0
					AND CD.[SystemBaseName] != 'SKS'
			) AS CD
		) AS CD
		OUTER APPLY
		(
			SELECT TOP (1) DD.[CD_ID_CLIENT]
			FROM [dbo].[ClientDistrView] AS D
			INNER JOIN [DBF].[dbo.ClientDistrView] AS DD ON DD.[DIS_NUM] = D.[DISTR] AND DD.[DIS_COMP_NUM] = D.[COMP] AND DD.[SYS_REG_NAME] = D.[SystemBaseName]
			WHERE D.[ID_CLIENT] = C.[ClientID]
		) AS DC
		OUTER APPLY
		(
			SELECT
				[IsLong] =
					CASE WHEN EXISTS
						(
							SELECT *
							FROM [DBF].[dbo].[DistrFinancingView] AS DF
							WHERE DF.[CD_ID_CLIENT] = DC.[CD_ID_CLIENT]
								AND DF.[DF_EXPIRE] IS NOT NULL
						) THEN 1
						ELSE 0
					END
		) AS DL
		OUTER APPLY
		(
			SELECT
				[ToxicWords] = String_Agg(Convert(VarChar(20), [IN_DATE], 104) + ' ' + W.[Mask], Char(10)) WITHIN GROUP (ORDER BY [IN_DATE] DESC)
			FROM
			(
				SELECT DISTINCT
					I.[IN_DATE], W.[Mask]
				FROM [DBF].[dbo].[IncomeTable] AS I
				INNER JOIN [DBF].[Raw].[Incomes:Details] AS D ON D.[Id] = I.[Raw_Id]
				INNER JOIN [DBF].[dbo].[PurposesForbiddenWords] AS W ON D.[Purpose] LIKE W.[Mask]
				WHERE I.[IN_ID_CLIENT] = DC.[CD_ID_CLIENT]
			) AS W
		) AS W
		WHERE C.[STATUS] = 1
			AND C.[StatusID] IN (SELECT S.[ServiceStatusId] FROM [dbo].[ServiceStatusConnected]() AS S)
			AND C.[ID_HEAD] IS NULL
			-- AND исключить бесплатных клиентов
			AND P.[PayTypeName] NOT IN ('не оплачивает', 'бесплатно РДД')
		ORDER BY C.[ClientFullName]

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_QUALITY_REPORT] TO rl_client_quality_report;
GO
