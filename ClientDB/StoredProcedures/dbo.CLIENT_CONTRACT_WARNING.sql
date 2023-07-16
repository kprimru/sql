USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_CONTRACT_WARNING]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_WARNING]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTRACT_WARNING]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@ControlDate			SmallDateTime,
		@Setting_CONTRACT_OLD	Bit;

	DECLARE @Clients Table
	(
		[Client_Id]			Int,
		[ClientFullName]	VarChar(512),
		[ManagerName]		VarChar(100)
		PRIMARY KEY CLUSTERED([Client_Id])
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY
		SET @ControlDate = dbo.DateOf(DateAdd(Month, 1, GetDate()));
		SET @Setting_CONTRACT_OLD = Cast([System].[Setting@Get]('CONTRACT_OLD') AS Bit);

		INSERT INTO @Clients
		SELECT W.[WCL_ID], C.[ClientFullname], C.[ManagerName]
		FROM [dbo].[ClientList@Get?Write]()			AS W
		INNER JOIN [dbo].[ClientView]				AS C WITH(NOEXPAND) ON W.[WCL_ID] = C.[ClientID]
		INNER JOIN [dbo].[ServiceStatusConnected]() AS S ON C.[ServiceStatusId] = S.[ServiceStatusId]

		SELECT
			[ClientID]			= C.[Client_Id],
			[ClientFullName]	= C.[ClientFullName],
			[ManagerName]		= C.[ManagerName],
			[ContractEnd]		= D.[ExpireDate]
		FROM @Clients							AS C
		INNER JOIN [Contract].[ClientContracts] AS CC ON CC.[Client_Id] = C.[Client_Id]
		INNER JOIN [Contract].[Contract]		AS CO ON CO.[ID] = CC.[Contract_Id]
		CROSS APPLY
		(
			SELECT TOP (1) D.[ExpireDate]
			FROM [Contract].[ClientContractsDetails] D
			WHERE D.[Contract_Id] = CO.[ID]
			ORDER BY D.[DATE] DESC
		) D
		WHERE	CO.[DateTo] IS NULL
			AND D.[ExpireDate] <= @ControlDate
			AND @Setting_CONTRACT_OLD = 0

		UNION ALL

		SELECT
			[ClientID]			= C.[Client_Id],
			[ClientFullName]	= C.[ClientFullName],
			[ManagerName]		= C.[ManagerName],
			[ContractEnd]		= MAX(CO.[ContractEnd])
		FROM @Clients						AS C
		INNER JOIN [dbo].[ContractTable]	AS CO ON CO.[ClientID] = C.[Client_Id]
		WHERE CO.[ContractEnd] <= @ControlDate
			AND NOT EXISTS
				(
					SELECT *
					FROM [dbo].[ContractTable] AS E
					WHERE E.[ClientID] = CO.[ClientID]
						AND E.[ContractEnd] >= @ControlDate
				)
			AND
			(
			    NOT EXISTS
				(
					SELECT *
					FROM [Contract].[ClientContracts] AS CC
					WHERE CC.[Client_Id] = C.[Client_Id]
				)
				OR @Setting_CONTRACT_OLD = 1
			)
		GROUP BY C.[Client_Id], C.[ClientFullName], C.[ManagerName]

		ORDER BY [ClientFullName]

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTRACT_WARNING] TO rl_contract_warning;
GO
