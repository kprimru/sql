USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Дата создания: 18.11.2008
Описание:	  Удалить хост с указанным 
               кодом из справочника
*/

CREATE PROCEDURE [dbo].[HOST_DELETE] 
	@hostid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.HostTable WHERE HST_ID = @hostid

	SET NOCOUNT OFF
END


