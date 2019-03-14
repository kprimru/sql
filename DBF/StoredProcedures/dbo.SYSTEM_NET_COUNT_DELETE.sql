USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Дата создания: 23.09.2008
Описание:	  Удалить данные о кол-ве станций 
               типа сети с указанным ID из справочника
*/

CREATE PROCEDURE [dbo].[SYSTEM_NET_COUNT_DELETE] 
	@systemnetcountid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.SystemNetCountTable WHERE SNC_ID = @systemnetcountid

	SET NOCOUNT OFF
END