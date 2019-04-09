USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONTRACT_PAY_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ContractPayName, ContractPayDay, ContractPayMonth
	FROM dbo.ContractPayTable
	WHERE ContractPayID = @ID
END