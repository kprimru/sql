USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[ACTION_TYPE_TRY_DELETE] 
	@ID SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.Action WHERE ACTN_ID_TYPE = @ID)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Данный тип акции указан в одной или нескольких акциях. ' + 
							  'Удаление невозможно, пока выбранный тип акции будет указан хотя ' +
							  'бы в одной акции.'
		END

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END
