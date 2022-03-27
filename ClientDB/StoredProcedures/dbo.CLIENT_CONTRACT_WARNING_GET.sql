USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_CONTRACT_WARNING_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_WARNING_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTRACT_WARNING_GET]
	@CLIENT		INT,
	@WARN_COUNT	INT = NULL OUTPUT
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

		SET @WARN_COUNT =
			(
				SELECT COUNT(*)
				FROM dbo.ClientTable a
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
				INNER JOIN [dbo].[ClientList@Get?Write]() ON WCL_ID = ClientID
				WHERE ClientID = @CLIENT
					AND NOT EXISTS
							(
								SELECT *
								FROM dbo.ContractTable e
								WHERE e.ClientID = a.ClientID
									AND e.ContractEnd >= dbo.DateOf(GETDATE())
							)
					AND NOT EXISTS
						(
							SELECT *
							FROM Contract.ClientContracts CC
							INNER JOIN Contract.Contract C ON C.ID = CC.Contract_Id
							CROSS APPLY
							(
								SELECT TOP (1) ExpireDate
								FROM Contract.ClientContractsDetails D
								WHERE D.Contract_Id = C.ID
								ORDER BY DATE DESC
							) D
							WHERE CC.Client_Id = a.ClientID
								AND C.DateTo IS NULL
								AND D.ExpireDate >= dbo.DateOf(GETDATE())
						)

			);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTRACT_WARNING_GET] TO rl_client_contract_u;
GO
