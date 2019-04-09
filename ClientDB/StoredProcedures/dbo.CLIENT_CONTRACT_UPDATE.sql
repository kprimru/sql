USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_UPDATE]
	@ID		INT,
	@CLIENT	INT,
	@NUM	VARCHAR(100),
	@YEAR	VARCHAR(10),
	@TYPE	INT,
	@PAY	INT,
	@DISC	INT,
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@COND	VARCHAR(250),
	@DATE	SMALLDATETIME = NULL,
	@ID_FOUND	UNIQUEIDENTIFIER = NULL,
	@FOUND_END	SMALLDATETIME = NULL,
	@FIXED		MONEY = NULL
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ContractTable
	SET	ContractNumber	=	@NUM, 
		ContractYear	=	@YEAR, 
		ContractTypeID	=	@TYPE, 
		ContractBegin	=	@BEGIN,
		ContractEnd		=	@END, 
		ContractConditions	=	@COND, 
		ContractPayID	=	@PAY, 
		DiscountID		=	@DISC,
		ContractDate = @DATE,
		--ID_FOUNDATION = @ID_FOUND,
		--FOUND_END = @FOUND_END,
		ContractFixed = @FIXED
	WHERE ContractID = @ID
END