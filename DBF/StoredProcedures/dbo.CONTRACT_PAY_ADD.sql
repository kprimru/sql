USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[CONTRACT_PAY_ADD] 
	@name VARCHAR(100),
	@day TINYINT,
	@month TINYINT,
	@active BIT = 1,	
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.ContractPayTable(COP_NAME, COP_DAY, COP_MONTH, COP_ACTIVE) 
	VALUES (@name, @day, @month, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END




