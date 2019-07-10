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

CREATE PROCEDURE [dbo].[CONTRACT_PAY_EDIT] 
	@id SMALLINT,
	@name VARCHAR(100),
	@day TINYINT,
	@month TINYINT,
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.ContractPayTable 
	SET COP_NAME = @name, 
		COP_DAY = @day,
		COP_MONTH = @month,
		COP_ACTIVE = @active
	WHERE COP_ID = @id

	SET NOCOUNT OFF
END