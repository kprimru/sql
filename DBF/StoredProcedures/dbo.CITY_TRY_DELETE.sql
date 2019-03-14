USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
-- =============================================
-- јвтор:		  ƒенисов јлексей
-- ƒата создани€: 25.08.2008
-- ќписание:	  ¬озвращает 0, если населенный пункт 
--                можно удалить из справочника (ни 
--                одна улица и ни один банк не ссылает 
--                на данный населенный пункт), 
--                -1 в противном случае
-- =============================================

CREATE PROCEDURE [dbo].[CITY_TRY_DELETE] 
  @cityid int

AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.StreetTable WHERE ST_ID_CITY = @cityid) 
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'ƒанный населенный пункт указан у одной или нескольких улиц. ' + 
							  '”даление невозможно, пока выбранный населенный пункт будет указан хот€ ' +
							  'бы у одной улицы.' + CHAR(13)
		END
	   
	IF EXISTS(SELECT * FROM dbo.BankTable WHERE BA_ID_CITY = @cityid) 
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'ƒанный населенный пункт указан у одного или нескольких банков. ' + 
						  '”даление невозможно, пока выбранный населенный пункт будет указан хот€ ' +
						  'бы у одного банка.' + CHAR(13)
		END

	-- добавлено 4.05.2009
	IF EXISTS(SELECT * FROM dbo.SubhostCityTable WHERE SC_ID_CITY = @cityid) 
		BEGIN
			SET @res = 1
			SET @txt = @txt + '”даление невозможно, так как данный населенный пункт' 
							+ 'указан в записи городов подхостов.'
		END


	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF
END

