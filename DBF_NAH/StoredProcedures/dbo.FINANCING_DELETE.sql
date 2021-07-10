USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Удалить из справочника тип
               финансирования с указанным кодом
*/

ALTER PROCEDURE [dbo].[FINANCING_DELETE]
	@financingid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.FinancingTable
	WHERE FIN_ID = @financingid

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[FINANCING_DELETE] TO rl_financing_d;
GO