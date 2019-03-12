USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ContractNumber, ContractYear, ContractTypeID, 
		ContractBegin, ContractEnd, ContractConditions, 
		ContractPayID, DiscountID, ContractDate, 
		ID_FOUNDATION, FOUND_END, ContractFixed
	FROM dbo.ContractTable
	WHERE ContractID = @ID
END