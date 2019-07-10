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

CREATE PROCEDURE [dbo].[TAX_GET] 
	@taxid INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT TX_ID, TX_NAME, TX_PERCENT, TX_CAPTION, TX_ACTIVE
	FROM dbo.TaxTable 
	WHERE TX_ID = @taxid 
	
	SET NOCOUNT OFF
END
