USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Изменить данные о поле в справочнике полей
*/

CREATE PROCEDURE [dbo].[FIELD_EDIT] 
	@fieldid INT,
	@fieldname VARCHAR(50),
	@fieldwidth INT,
	@fieldcaption VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.FieldTable 
	SET FL_NAME = @fieldname, 
		FL_WIDTH = @fieldwidth, 
		FL_CAPTION = @fieldcaption 
	WHERE FL_ID = @fieldid

	SET NOCOUNT OFF
END
