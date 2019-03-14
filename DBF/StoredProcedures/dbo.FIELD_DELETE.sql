USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Удалить поле из справочника полей
*/

CREATE PROCEDURE [dbo].[FIELD_DELETE] 
	@fieldid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.FieldTable WHERE FL_ID = @fieldid

	SET NOCOUNT OFF
END

