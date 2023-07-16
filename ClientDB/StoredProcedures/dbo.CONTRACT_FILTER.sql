USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONTRACT_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONTRACT_FILTER]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CONTRACT_FILTER]
	@Date			SmallDateTime	= NULL,
	@Statuses		VarChar(Max)	= NULL,
	@Managers		VarChar(Max)	= NULL,
	@Services		VarChar(Max)	= NULL,
	@PayTypes		VarChar(Max)	= NULL,
	@ContractTypes	VarChar(Max)	= NULL,
	@FlowTypes		VarChar(Max)	= NULL,
	@ActSignPeriods	VarChar(Max)	= NULL,
	@Discounts		VarChar(Max)	= NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Setting_CONTRACT_OLD	Bit;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @Date = IsNull(@Date, GetDate());
		SET @Setting_CONTRACT_OLD = Cast([System].[Setting@Get]('CONTRACT_OLD') AS Bit);

        IF @Setting_CONTRACT_OLD = 1
            SELECT
				[Client_Id]				= CL.[ClientID],
				[ClientFullName]		= CL.[ClientFullName],
				[ServiceStatusIndex]	= CL.[ServiceStatusIndex],
				[Manager_Id]			= CL.[ManagerID],
				[Service_Id]			= CL.[ServiceID],
				[SignDate]				= C.[ContractDate],
				[Number]				= C.[ContractNumber],
				[DateFrom]				= C.[ContractBegin],
				[DateTo]				= C.[ContractEnd],
				[Type_Id]				= C.[ContractTypeID],
				[PayType_Id]			= C.[ContractPayID],
				[Discount_Id]			= C.[DiscountID],
				[ExpireDate]			= NULL,
				[DocumentFlowType_Id]	= NULL,
				[ActSignPeriod_Id]		= NULL,
				[DistrsList]			= CD.[DistrsList]
	        FROM [dbo].[ClientReadList]()			AS R
		    INNER JOIN [dbo].[ClientView]			AS CL WITH(NOEXPAND) ON CL.[ClientID] = R.[RCL_ID]
			INNER JOIN [dbo].[ContractTable]		AS C ON C.[ClientID] = CL.[ClientID]
			OUTER APPLY
			(
				SELECT [DistrsList] = String_Agg(CD.[SystemShortName], ', ') WITHIN GROUP (ORDER BY [SystemOrder])
				FROM
				(
					SELECT DISTINCT CD.[SystemShortName], CD.[SystemOrder]
					FROM [dbo].[ClientDistrView] AS CD WITH(NOEXPAND)
					WHERE CD.[ID_CLIENT] = CL.[ClientID]
						-- TODO: значение на "сейчас", а фильтр на дату работает. Нехорошо
						AND CD.[DS_REG] = 0
				) AS CD
			) AS CD
	        WHERE @Date BETWEEN C.[ContractBegin] AND C.[ContractEnd]
				AND (CL.[ServiceStatusID] IN (SELECT S.[Id] FROM dbo.TableIDFromXML(@Statuses) AS S) OR @Statuses IS NULL)
				AND (CL.[ManagerID] IN (SELECT S.[Id] FROM dbo.TableIDFromXML(@Managers) AS S) OR @Managers IS NULL)
				AND (CL.[ServiceID] IN (SELECT S.[Id] FROM dbo.TableIDFromXML(@Services) AS S) OR @Services IS NULL)
				AND (C.[ContractPayID] IN (SELECT S.[Id] FROM dbo.TableIDFromXML(@PayTypes) AS S) OR @PayTypes IS NULL)
				AND (C.[ContractTypeID] IN (SELECT S.[Id] FROM dbo.TableIDFromXML(@ContractTypes) AS S) OR @ContractTypes IS NULL)
				--AND (CL.[ServiceStatusID] IN (SELECT S.[Id] FROM dbo.TableIDFromXML(@FlowTypes) AS S) OR @FlowTypes IS NULL)
				AND (C.[DiscountID] IN (SELECT S.[Id] FROM dbo.TableIDFromXML(@Discounts) AS S) OR @Discounts IS NULL)
	        ORDER BY ClientFullName, ContractEnd DESC;
        ELSE
			SELECT
				[Client_Id]				= CL.[ClientID],
				[ClientFullName]		= CL.[ClientFullName],
				[ServiceStatusIndex]	= CL.[ServiceStatusIndex],
				[Manager_Id]			= CL.[ManagerID],
				[Service_Id]			= CL.[ServiceID],
				[SignDate]				= C.[SignDate],
				[Number]				= C.[NUM_S],
				[DateFrom]				= C.[DateFrom],
				[DateTo]				= C.[DateTo],
				[Type_Id]				= D.[Type_Id],
				[PayType_Id]			= D.[PayType_Id],
				[Discount_Id]			= D.[Discount_Id],
				[ExpireDate]			= D.[ExpireDate],
				[DocumentFlowType_Id]	= D.[DocumentFlowType_Id],
				[ActSignPeriod_Id]		= D.[ActSignPeriod_Id],
				[DistrsList]			= CD.[DistrsList]
	        FROM [dbo].[ClientList@Get?Read]()		AS R
		    INNER JOIN [dbo].[ClientView]			AS CL WITH(NOEXPAND) ON CL.[ClientID] = R.[WCL_ID]
			INNER JOIN [Contract].[ClientContracts]	AS CC ON CC.[Client_Id] = CL.[ClientID]
		    INNER JOIN [Contract].[Contract]		AS C ON C.[ID] = CC.[Contract_Id]
		    CROSS APPLY
		    (
			    SELECT TOP (1) D.[PayType_Id], D.[Discount_Id], D.[DocumentFlowType_Id], D.[Type_Id], D.[ExpireDate], D.[ActSignPeriod_Id]
			    FROM [Contract].[ClientContractsDetails] D
			    WHERE D.[Contract_Id] = C.[ID]
					AND D.[DATE] <= @Date
			    ORDER BY D.[DATE] DESC
		    ) D
			OUTER APPLY
			(
				SELECT [DistrsList] = String_Agg(CD.[SystemShortName], ', ') WITHIN GROUP (ORDER BY [SystemOrder])
				FROM
				(
					SELECT DISTINCT CD.[SystemShortName], CD.[SystemOrder]
					FROM [dbo].[ClientDistrView] AS CD WITH(NOEXPAND)
					WHERE CD.[ID_CLIENT] = CL.[ClientID]
						-- TODO: значение на "сейчас", а фильтр на дату работает. Нехорошо
						AND CD.[DS_REG] = 0
				) AS CD
			) AS CD
	        WHERE @Date >= C.[DateFrom]
				AND (@Date <= C.[DateTo] OR C.[DateTo] IS NULL)
				AND (CL.[ServiceStatusID] IN (SELECT S.[Id] FROM dbo.TableIDFromXML(@Statuses) AS S) OR @Statuses IS NULL)
				AND (CL.[ManagerID] IN (SELECT S.[Id] FROM dbo.TableIDFromXML(@Managers) AS S) OR @Managers IS NULL)
				AND (CL.[ServiceID] IN (SELECT S.[Id] FROM dbo.TableIDFromXML(@Services) AS S) OR @Services IS NULL)
				AND (D.[PayType_Id] IN (SELECT S.[Id] FROM dbo.TableIDFromXML(@PayTypes) AS S) OR @PayTypes IS NULL)
				AND (D.[Type_Id] IN (SELECT S.[Id] FROM dbo.TableIDFromXML(@ContractTypes) AS S) OR @ContractTypes IS NULL)
				AND (D.[DocumentFlowType_Id] IN (SELECT S.[Id] FROM dbo.TableIDFromXML(@FlowTypes) AS S) OR @FlowTypes IS NULL)
				AND (D.[ActSignPeriod_Id] IN (SELECT S.[Id] FROM dbo.TableIDFromXML(@ActSignPeriods) AS S) OR @ActSignPeriods IS NULL)
				AND (D.[Discount_Id] IN (SELECT S.[Id] FROM dbo.TableIDFromXML(@Discounts) AS S) OR @Discounts IS NULL)
	        ORDER BY CL.[ClientFullName], D.[ExpireDate] DESC;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CONTRACT_FILTER] TO rl_contract_filter;
GO
