USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_CONTRACT_OUT_DATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[GET_CONTRACT_OUT_DATE]  AS SELECT 1')
GO
-- получение просроченных договоров

CREATE OR ALTER PROCEDURE [dbo].[GET_CONTRACT_OUT_DATE]
	@curdate VARCHAR(20),
	@managerid INT = NULL,
	@statusid INT = 2
AS
BEGIN
	SET NOCOUNT ON

	--ToDo сделать нормально

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF @managerid IS NULL
			SELECT ClientTable.ClientID, ClientFullName,
			   Max(ContractBegin) AS ContractBeginStr,
			   Max(ContractEnd) AS ContractEndStr, ServiceName
			FROM dbo.ContractTable LEFT OUTER JOIN
					   dbo.ClientTable ON ClientTable.ClientID = ContractTable.ClientID LEFT OUTER JOIN
					   dbo.ServiceTable ON ClientTable.ClientServiceID = ServiceTable.ServiceID
			WHERE NOT EXISTS(SELECT ContractNumber FROM dbo.ContractTable WHERE (ContractBegin <= @curdate AND ContractEnd >= @curdate) AND ContractTable.CLientID = ClientTable.ClientID) AND StatusID = @statusid AND STATUS = 1
			GROUP BY ClientTable.ClientID, CLientFullName, ServiceName
			ORDER BY ServiceName, ClientFullName
		ELSE
		BEGIN
			DECLARE @t TABLE (Item INT)

			IF (@managerid = 19) OR (@managerid = 11)
				INSERT INTO @t
					SELECT 19 AS Item
					UNION
					SELECT 11 AS Item
			ELSE
				INSERT INTO @t
					SELECT @managerid AS Item


			SELECT ClientTable.ClientID, ClientFullName,
			   Max(ContractBegin) AS ContractBeginStr,
			   Max(ContractEnd) AS ContractEndStr, ServiceName
			FROM dbo.ContractTable LEFT OUTER JOIN
					   dbo.ClientTable ON ClientTable.ClientID = ContractTable.ClientID LEFT OUTER JOIN
					   dbo.ServiceTable ON ClientTable.ClientServiceID = ServiceTable.ServiceID
			WHERE NOT EXISTS(SELECT ContractNumber FROM dbo.ContractTable WHERE (ContractBegin <= @curdate AND ContractEnd >= @curdate) AND ContractTable.CLientID = ClientTable.ClientID)
				AND ManagerID IN
					(
						SELECT Item
						FROM @t
					)
				AND StatusID = @statusid
				AND STATUS = 1
			GROUP BY ClientTable.ClientID, CLientFullName, ServiceName
			ORDER BY ServiceName, ClientFullName
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[GET_CONTRACT_OUT_DATE] TO rl_contract_audit;
GO
