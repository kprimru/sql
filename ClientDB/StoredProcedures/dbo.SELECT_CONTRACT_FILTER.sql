USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SELECT_CONTRACT_FILTER]
	@MANAGER	INT,
	@SERVICE	INT,
	@STATUS		INT,
	@PAY		INT,
	@TYPE		INT
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
			ContractID = C.ID, ClientFullName, ManagerName, MaxContractEnd = ExpireDate, ContractDate = SignDate,
			ContractNumber = NUM_S, ServiceStatusName, ContractTypeName, 
			ServiceName, ContractPayName,
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
		FROM dbo.ClientReadList()			R
		INNER JOIN Contract.ClientContracts	CC	ON CC.Client_Id = R.RCL_ID 
		INNER JOIN Contract.Contract		C	ON C.ID = CC.Contract_Id
		CROSS APPLY
		(
			SELECT TOP (1) PayType_Id, Discount_Id, Type_Id, ExpireDate
			FROM Contract.ClientContractsDetails D
			WHERE D.Contract_Id = C.ID
			ORDER BY DATE DESC
		) CD
		INNER JOIN dbo.ClientView CL WITH(NOEXPAND) ON CL.ClientID = R.RCL_ID
		INNER JOIN dbo.ContractTypeTable T ON T.ContractTypeID = CD.Type_Id
		INNER JOIN dbo.ContractPayTable P ON P.ContractPayID = CD.PayType_Id
		WHERE DateTo IS NULL
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ServiceStatusID = @STATUS	OR @STATUS IS NULL)
			AND (P.ContractPayID = @PAY OR @PAY IS NULL)
			AND (T.ContractTypeID = @TYPE OR @TYPE IS NULL)
		ORDER BY ClientFullName, ExpireDate DESC
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END