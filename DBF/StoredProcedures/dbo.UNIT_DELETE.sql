USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Дата создания: 18.12.2008
Описание:	  Удалить технологический признак 
               с указанным кодом из справочника
*/

CREATE PROCEDURE [dbo].[UNIT_DELETE] 
	@unitid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.UnitTable 
	WHERE UN_ID = @unitid

	SET NOCOUNT OFF
END
