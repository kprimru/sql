USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONTRACT_PAY_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ContractPayID, ContractPayName, ContractPayDay, ContractPayMonth
	FROM dbo.ContractPayTable
	WHERE @FILTER IS NULL
		OR ContractPayName LIKE @FILTER
	ORDER BY ContractPayDay, ContractPayMonth, ContractPayName
END