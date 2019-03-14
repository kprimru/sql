USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	/*
Автор:		  Денисов Алексей
Дата создания: 15.10.2008
Описание:	  Удалить регион с указанным 
               кодом из справочника
*/
CREATE PROCEDURE [dbo].[QUARTER_DELETE] 
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.Quarter
	WHERE QR_ID = @id
END
