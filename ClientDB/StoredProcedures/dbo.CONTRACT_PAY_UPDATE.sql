USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONTRACT_PAY_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100),
	@DAY	SMALLINT,
	@MONTH	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ContractPayTable
	SET ContractPayName = @NAME,
		ContractPayDay	=	@DAY,
		ContractPayMonth	=	@MONTH,
		ContractPayLast = GETDATE()
	WHERE ContractPayID = @ID
END