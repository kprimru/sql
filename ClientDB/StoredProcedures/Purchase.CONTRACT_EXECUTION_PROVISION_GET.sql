USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Purchase].[CONTRACT_EXECUTION_PROVISION_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CEP_NAME, CEP_SHORT
	FROM Purchase.ContractExecutionProvision
	WHERE CEP_ID = @ID
END