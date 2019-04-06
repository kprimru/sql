USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 15.10.2008
Описание:	  Удалить подхост из справочника
*/

CREATE PROCEDURE [dbo].[SUBHOST_DELETE] 
	@subhostid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.SubhostTable 
	WHERE SH_ID = @subhostid

	SET NOCOUNT OFF
END