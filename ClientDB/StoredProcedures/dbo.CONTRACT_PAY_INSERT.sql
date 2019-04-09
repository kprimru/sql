USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONTRACT_PAY_INSERT]
	@NAME	VARCHAR(100),
	@DAY	SMALLINT,
	@MONTH	SMALLINT,
	@ID	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.ContractPayTable(ContractPayName, ContractPayDay, ContractPayMonth)
		VALUES(@NAME, @DAY, @MONTH)

	SELECT @ID = SCOPE_IDENTITY()
END