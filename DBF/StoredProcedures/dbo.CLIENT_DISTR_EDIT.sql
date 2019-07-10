USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:         Денисов Алексей
Описание:      Изменить данные о дистрибутиве клиента
*/

CREATE PROCEDURE [dbo].[CLIENT_DISTR_EDIT] 
	@id INT,
	@distrid INT,  
	@regdate SMALLDATETIME,
	@systemserviceid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.ClientDistrTable 
	SET CD_ID_DISTR = @distrid, 
		CD_REG_DATE = @regdate, 
		CD_ID_SERVICE = @systemserviceid 
	WHERE CD_ID = @id

	SET NOCOUNT OFF
END





