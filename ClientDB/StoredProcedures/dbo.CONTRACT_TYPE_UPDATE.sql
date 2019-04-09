USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONTRACT_TYPE_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100),
	@RATE	BIT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ContractTypeTable
	SET ContractTypeName = @NAME,
		ContractTypeRate = @RATE,
		ContractTypeLast = GETDATE()
	WHERE ContractTypeID = @ID
END