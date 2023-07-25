USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SELECT_CONTRACT_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SELECT_CONTRACT_FILTER]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[_SELECT_CONTRACT_FILTER]
	@MANAGER	INT,
	@SERVICE	INT,
	@STATUS		INT,
	@PAY		INT,
	@TYPE		INT,
	@FLOW		INT
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

		SET @Setting_CONTRACT_OLD = Cast([System].[Setting@Get]('CONTRACT_OLD') AS Bit);

        IF @Setting_CONTRACT_OLD = 1
            SELECT
		        ContractID, ClientFullName, ManagerName, ContractEnd AS MaxContractEnd, ContractDate,
		        ContractNumber, ServiceStatusName, ContractTypeName,
		        ServiceName, ContractPayName,
		        REVERSE(STUFF(REVERSE(
			        (
				        SELECT SystemShortName + ', '
				        FROM
					        (
						        SELECT DISTINCT SystemShortName, SystemOrder
						        FROM
							        dbo.ClientDistrView z WITH(NOEXPAND)
						        WHERE z.ID_CLIENT = a.ClientID AND DS_REG = 0
					        ) AS o_O
				        ORDER BY SystemOrder FOR XML PATH('')
			        )
		        ), 1, 2, '')) AS SystemList
	        FROM
		        dbo.ClientReadList()
		        INNER JOIN dbo.ContractTable a ON RCL_ID = ClientID
		        INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID 
		        INNER JOIN dbo.ContractTypeTable e ON a.ContractTypeID = e.ContractTypeID
		        INNER JOIN dbo.ContractPayTable f ON f.ContractPayID = a.ContractPayID
	        WHERE ContractEnd =
		        (
			        SELECT Max(z.ContractEnd) AS MaxContractEnd
			        FROM dbo.ContractTable z
			        WHERE a.ClientID = z.ClientID
		        )
		        AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
		        AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
		        AND (ServiceStatusID = @STATUS	OR @STATUS IS NULL)
		        AND (f.ContractPayID = @PAY OR @PAY IS NULL)
		        AND (e.ContractTypeID = @TYPE OR @TYPE IS NULL)
	        ORDER BY ClientFullName, ContractEnd DESC
        ELSE
		    SELECT
			    ContractID = C.ID, ClientFullName, ManagerName, MaxContractEnd = ExpireDate, ContractDate = SignDate,
			    ContractNumber = NUM_S, ServiceStatusName, ContractTypeName,
			    ServiceName, ContractPayName, [FlowTypeName] = F.Name,
			    REVERSE(STUFF(REVERSE(
				    (
					    SELECT SystemShortName + ', '
					    FROM
						    (
							    SELECT DISTINCT SystemShortName, SystemOrder
							    FROM
								    dbo.ClientDistrView z WITH(NOEXPAND)
							    WHERE z.ID_CLIENT = CL.ClientID AND DS_REG = 0
						    ) AS o_O
					    ORDER BY SystemOrder FOR XML PATH('')
				    )
			    ), 1, 2, '')) AS SystemList
		    FROM [dbo].[ClientList@Get?Read]()	R
		    INNER JOIN Contract.ClientContracts	CC	ON CC.Client_Id = R.WCL_ID
		    INNER JOIN Contract.Contract		C	ON C.ID = CC.Contract_Id
		    CROSS APPLY
		    (
			    SELECT TOP (1) PayType_Id, Discount_Id, DocumentFlowType_Id, Type_Id, ExpireDate
			    FROM Contract.ClientContractsDetails D
			    WHERE D.Contract_Id = C.ID
			    ORDER BY DATE DESC
		    ) CD
		    INNER JOIN dbo.ClientView CL WITH(NOEXPAND) ON CL.ClientID = R.WCL_ID
		    INNER JOIN dbo.ContractTypeTable T ON T.ContractTypeID = CD.Type_Id
		    INNER JOIN dbo.ContractPayTable P ON P.ContractPayID = CD.PayType_Id
			LEFT JOIN [Contract].[Contracts->Documents Flow Types] AS F ON F.[Id] = CD.[DocumentFlowType_Id]
		    WHERE DateTo IS NULL
			    AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
			    AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			    AND (ServiceStatusID = @STATUS	OR @STATUS IS NULL)
			    AND (P.ContractPayID = @PAY OR @PAY IS NULL)
			    AND (T.ContractTypeID = @TYPE OR @TYPE IS NULL)
				AND (F.Id = @FLOW OR @FLOW IS NULL)
		    ORDER BY ClientFullName, ExpireDate DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SELECT_CONTRACT_FILTER] TO rl_filter_contract_type;
GO
