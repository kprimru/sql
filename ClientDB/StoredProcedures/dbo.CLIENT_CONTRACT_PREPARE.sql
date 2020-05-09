USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTRACT_PREPARE]
	@CLIENT	INT,
	@TEXT	VARCHAR(100) = NULL OUTPUT,
	@COLOR	INT	= NULL OUTPUT
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

		SET @TEXT = NULL

		SET @COLOR = 0

		IF NOT EXISTS
			(
				SELECT *
				FROM dbo.ContractTable
				WHERE ClientID = @CLIENT
					AND GETDATE() BETWEEN ContractBegin AND ContractEnd
			) AND
			(
				SELECT StatusID
				FROM dbo.ClientTable
				WHERE ClientID = @CLIENT
			) = 2
			SET @COLOR = 1
		ELSE IF EXISTS
			(
				SELECT *
				FROM dbo.ContractTable
				WHERE ClientID = @CLIENT
					AND (ContractEnd BETWEEN GetDate() AND DATEADD(MONTH, 1, GETDATE()))
			) AND
			(
				SELECT StatusID
				FROM dbo.ClientTable
				WHERE ClientID = @CLIENT
			) = 2
			SET @COLOR = 2

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTRACT_PREPARE] TO rl_client_contract_r;
GO