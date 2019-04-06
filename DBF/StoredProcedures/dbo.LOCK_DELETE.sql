USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 28.10.2008
Описание:	  Удаление блокировки с указанным 
               документом в указанной таблице
*/

CREATE PROCEDURE [dbo].[LOCK_DELETE] 
	@docid INT,
	@tablename VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.LockTable
	WHERE LC_DOC_ID = @docid AND LC_TABLE = @tablename

	SET NOCOUNT OFF	
END