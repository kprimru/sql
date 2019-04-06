USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Возвращает 0, если период можно 
               удалить из справочника (на него 
               не ссылается ни одна запись 
               из других таблиц), 
               -1 в противном случае
*/

CREATE PROCEDURE [dbo].[QUARTER_TRY_DELETE] 
	@periodid SMALLINT
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
