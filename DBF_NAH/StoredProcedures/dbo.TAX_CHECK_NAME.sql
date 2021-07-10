USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 13.01.2009
Описание:	  Возвращает ID налога
                с указанным названием.
*/

ALTER PROCEDURE [dbo].[TAX_CHECK_NAME]
	@taxname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT TX_ID
	FROM dbo.TaxTable
	WHERE TX_NAME = @taxname

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[TAX_CHECK_NAME] TO rl_tax_w;
GO