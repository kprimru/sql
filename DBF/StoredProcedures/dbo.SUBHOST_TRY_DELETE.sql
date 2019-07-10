USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 16.10.2008
Описание:	  Возвращает 0, если подхост можно 
               удалить из справочника (ни в 
               одной таблице он не указан), 
               -1 в противном случае
*/

CREATE PROCEDURE [dbo].[SUBHOST_TRY_DELETE] 
	@subhostid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	
	IF EXISTS(SELECT * FROM dbo.PeriodRegTable WHERE REG_ID_HOST = @subhostid)
		BEGIN
			-- изменено 4.05.2009
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить подхост, так как '
							+ 'имеются записи в истории рег.узла с данным подхостом.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.PeriodRegNewTable WHERE RNN_ID_HOST = @subhostid) 
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить подхост, так как '
							+ 'имеются записи о регистрации новых систем с данным подхостом.' + CHAR(13)
		END

	-- добавлено 29.04.2009, В.Богдан
	IF EXISTS(SELECT * FROM dbo.ClientTable WHERE CL_ID_SUBHOST = @subhostid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить подхост, так как ему занесены клиенты. ' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.RegNodeFullTable WHERE RN_ID_SUBHOST = @subhostid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить подхост, так как он указан на рег.узле.'
		END
	IF EXISTS(SELECT * FROM dbo.SubhostCityTable WHERE SC_ID_SUBHOST = @subhostid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить подхост, на него ссылаются записи о городах подхостов.'
		END
	
	-- 

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF
END


