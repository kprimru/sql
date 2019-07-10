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

CREATE PROCEDURE [dbo].[COUNTRY_TRY_DELETE] 
	@countryid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.CityTable WHERE CT_ID_COUNTRY = @countryid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + 'Данная страна указана у одного или нескольких населенных пунктов. ' + 
						  'Удаление невозможно, пока выбранная страна будет указан хотя ' +
						  'бы у одного населенного пункта.'
	  END

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END