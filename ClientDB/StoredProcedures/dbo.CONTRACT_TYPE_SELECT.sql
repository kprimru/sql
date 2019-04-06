USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONTRACT_TYPE_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ContractTypeID, ContractTypeName, ContractTypeRate, ContractTypeHst
	FROM dbo.ContractTypeTable
	WHERE @FILTER IS NULL
		OR ContractTypeName LIKE @FILTER
	ORDER BY ContractTypeName
END