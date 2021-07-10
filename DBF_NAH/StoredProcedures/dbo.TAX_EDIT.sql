USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[TAX_EDIT]
	@id INT,
	@name VARCHAR(100),
	@percent DECIMAL(8, 4),
	@caption VARCHAR(50) ,
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.TaxTable
	SET TX_NAME = @name,
		TX_PERCENT = @percent,
		TX_CAPTION = @caption,
		TX_ACTIVE = @active
	WHERE TX_ID = @id

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[TAX_EDIT] TO rl_tax_w;
GO