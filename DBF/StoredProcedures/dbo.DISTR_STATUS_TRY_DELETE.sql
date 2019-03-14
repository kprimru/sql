USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Дата создания: 30.01.2009
Описание:	  Возвращает 0, если дистрибутив с 
               указанным кодом можно удалить со 
               склада, -1 в противном случае
*/

CREATE PROCEDURE [dbo].[DISTR_STATUS_TRY_DELETE] 
	@dsid SMALLINT
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







