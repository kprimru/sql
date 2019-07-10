USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей, Богдан Владимир
Дата создания:	25.08.2008, 3.06.2009
Описание:		Возвращает ID подхоста с указанным 
				названием подхоста на РЦ.
*/

CREATE PROCEDURE [dbo].[SUBHOST_CHECK_LST_NAME] 
	@subhostlstname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT SH_ID
	FROM dbo.SubhostTable
	WHERE SH_LST_NAME = @subhostlstname 

	SET NOCOUNT OFF
END
