USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_LAST]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ContractBegin, ContractEnd, ContractYear, ContractNumber, ContractTypeName, ContractConditions,
		c.NAME, a.FOUND_END
	FROM 
		dbo.ContractTable a
		INNER JOIN dbo.ContractTypeTable b ON a.ContractTypeID = b.ContractTypeID
		LEFT OUTER JOIN dbo.ContractFoundation c ON c.ID = a.ID_FOUNDATION
	WHERE ContractID = @ID
END