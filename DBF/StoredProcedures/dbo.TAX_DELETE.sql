USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Дата создания: 13.01.2009
Описание:	  Удалить налог из справочника
*/

CREATE PROCEDURE [dbo].[TAX_DELETE] 
	@taxid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.TaxTable 
	WHERE TX_ID = @taxid

	SET NOCOUNT OFF
END