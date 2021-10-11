USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GET_OLD_CONTRACT]
	@date SMALLDATETIME,
	@serviceid INT,
	@managerid INT,
	@statusid INT
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

		SELECT b.ClientID, ClientFullName, MAX(ContractBegin) AS ContractbeginStr, MAX(ContractEnd) AS ContrctEndStr
		FROM dbo.ClientTable b
		INNER JOIN dbo.ServiceTable ON ServiceID = ClientServiceID
		LEFT JOIN dbo.ContractTable a ON a.ClientID = b.ClientID
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ContractTable c
				WHERE c.ClientID = a.ClientID AND
					c.ContractBegin <= @date AND
					c.ContractEnd >= @date
			)
			AND (ClientServiceID = @serviceid OR @ServiceId IS NULL)
			AND (ManagerID = @managerid OR @ManagerId IS NULL)
			AND (StatusID = @statusid OR @StatusId IS NULL)
			AND STATUS = 1
			AND
			(   NOT EXISTS
				(
					SELECT *
					FROM Contract.ClientContracts CC
					WHERE CC.Client_Id = b.CLientID
				)
				OR [Maintenance].[GlobalContractOld]() = 1
			)
		GROUP BY b.ClientID, ClientFullName

		UNION ALL

		SELECT b.ClientID, ClientFullName, MAX(DateFrom) AS ContractbeginStr, MAX(DateTo) AS ContrctEndStr
		FROM dbo.ClientTable b
		INNER JOIN dbo.ServiceTable ON ServiceID = ClientServiceID
		INNER JOIN Contract.ClientContracts a ON a.Client_Id = b.ClientID
		INNER JOIN Contract.Contract Z ON a.Contract_Id = Z.ID
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Contract.Contract C
				INNER JOIN Contract.ClientContracts CC ON C.ID = CC.Contract_Id
				CROSS APPLY
				(
					SELECT TOP (1) D.ExpireDate
					FROM Contract.ClientContractsDetails D
					WHERE D.Contract_Id = C.ID
					ORDER BY D.DATE DESC
				) D
				WHERE CC.Client_Id = b.ClientID
					AND C.DateFrom <= @date
					AND (D.ExpireDate >= @date OR C.DateTo >= @date)
			)
			AND (ClientServiceID = @serviceid OR @ServiceId IS NULL)
			AND (ManagerID = @managerid OR @ManagerId IS NULL)
			AND (StatusID = @statusid OR @StatusId IS NULL)
			AND b.STATUS = 1
			AND [Maintenance].[GlobalContractOld]() = 0
		GROUP BY b.ClientID, ClientFullName

		ORDER BY ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[GET_OLD_CONTRACT] TO rl_contract_audit;
GO
