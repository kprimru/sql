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

CREATE PROCEDURE [dbo].[TAX_ADD]
	@name VARCHAR(100),
	@percent DECIMAL(8, 4),	
	@caption VARCHAR(50),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.TaxTable(TX_NAME, TX_PERCENT, TX_CAPTION, TX_ACTIVE) 
	VALUES (@name, @percent, @caption, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END
