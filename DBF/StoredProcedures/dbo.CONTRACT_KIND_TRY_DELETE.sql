USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Описание:	  Возвращает 0, если тип договора с 
                указанным кодом можно удалить 
                (на нее не ссылается ни один 
                договор клиента), 
                -1 в противном случае
*/

CREATE PROCEDURE [dbo].[CONTRACT_KIND_TRY_DELETE] 
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF
END
