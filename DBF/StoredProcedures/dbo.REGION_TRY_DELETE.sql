USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
јвтор:		  ƒенисов јлексей
ƒата создани€: 25.08.2008
ќписание:	  ¬озвращает 0, если регион можно 
               удалить из справочника (на него 
               не ссылаетс€ ни одна запись 
               из населенного пункта), 
                -1 в противном случае
*/

CREATE PROCEDURE [dbo].[REGION_TRY_DELETE] 
	@regionid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.CityTable WHERE CT_ID_RG = @regionid)
	BEGIN
		SET @res = 1
		SET @txt = @txt + 'ƒанный регион указан у одного или нескольких населенных пунктов. ' + 
						  '”даление невозможно, пока выбранный регион будет указан хот€ ' +
						  'бы у одного населенного пункта.'
	END

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END