USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 30.01.2009
Описание:	  Удалить статус дистриубтива
*/

CREATE PROCEDURE [dbo].[DISTR_STATUS_DELETE] 
	@distrstatusid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.DistrStatusTable 
	WHERE DS_ID = @distrstatusid

	SET NOCOUNT OFF
END