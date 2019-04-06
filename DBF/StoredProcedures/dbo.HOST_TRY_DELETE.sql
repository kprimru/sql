USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 18.11.2008
Описание:	  Возвращает 0, если хост 
               можно удалить, 
               -1 в противном случае
*/

CREATE PROCEDURE [dbo].[HOST_TRY_DELETE] 
	@hostid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.SystemTable WHERE SYS_ID_HOST = @hostid) 
	  BEGIN
		SET @res = 1
		SET @txt = @txt + 'Данный хост указан у одной или нескольких систем. ' + 
						  'Удаление невозможно, пока выбранный хост будет указан хотя ' +
						  'бы у одной системы.'
	  END
	      
	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END