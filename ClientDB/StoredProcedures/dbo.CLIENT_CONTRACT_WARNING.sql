USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTRACT_WARNING]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @Clients Table
	(
		Client_Id		Int,
		ClientFullName	VarChar(512),
		ManagerName		VarChar(100)
		PRIMARY KEY CLUSTERED(Client_Id)
	);

	DECLARE @CONTROL_DATE SMALLDATETIME

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY
		SET @CONTROL_DATE = dbo.DateOf(DATEADD(MONTH, 1, GETDATE()))

		INSERT INTO @Clients
		SELECT WCL_ID, ClientFullname, ManagerName
		FROM [dbo].[ClientList@Get?Write]()
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON WCL_ID = b.ClientID
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON b.ServiceStatusId = s.ServiceStatusId

		SELECT
			ClientID = B.[Client_Id], ClientFullName, ManagerName, ExpireDate AS ContractEnd
		FROM @Clients B
		INNER JOIN Contract.ClientContracts CC ON CC.Client_Id = b.Client_Id
		INNER JOIN Contract.Contract C ON C.ID = CC.Contract_Id
		CROSS APPLY
		(
			SELECT TOP (1) ExpireDate
			FROM Contract.ClientContractsDetails D
			WHERE D.Contract_Id = C.ID
			ORDER BY DATE DESC
		) D
		WHERE
			C.DateTo IS NULL
			AND D.ExpireDate <= @CONTROL_DATE

		UNION ALL

		SELECT
			ClientID = B.[Client_Id], ClientFullName, ManagerName, MAX(ContractEnd) AS ContractEnd
		FROM @Clients B
		INNER JOIN dbo.ContractTable a ON a.ClientID = b.Client_Id
		WHERE ContractEnd <= @CONTROL_DATE
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.ContractTable e
					WHERE e.ClientID = a.ClientID
						AND e.ContractEnd >= @CONTROL_DATE
				)
			AND NOT EXISTS
				(
					SELECT *
					FROM Contract.ClientContracts CC
					WHERE CC.Client_Id = b.Client_Id
				)
		GROUP BY b.Client_Id, ClientFullName, ManagerName

		ORDER BY ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_CONTRACT_WARNING] TO rl_contract_warning;
GO