USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Возвращает ID подхоста с указанным 
                полным названием. 
*/

CREATE PROCEDURE [dbo].[SUBHOST_CHECK_SHORT_NAME] 
	@subhostname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT SH_ID
	FROM dbo.SubhostTable
	WHERE SH_SHORT_NAME = @subhostname 

	SET NOCOUNT OFF
END