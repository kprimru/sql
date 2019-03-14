USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
јвтор:		  ƒенисов јлексей
ƒата создани€: 18.12.2008
ќписание:	  ¬озвращает 0, если технологический признак
               можно удалить, 
               -1 в противном случае
*/

CREATE PROCEDURE [dbo].[TECHNOL_TYPE_TRY_DELETE] 
	@technoltypeid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	-- добавлено 28.04.2009, ¬.Ѕогдан
	IF EXISTS(SELECT * FROM dbo.RegNodeFullTable WHERE RN_ID_TECH_TYPE = @technoltypeid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Ќевозможно удалить технологический признак, так как с ним был зарегистрирован дистрибутив.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.RegNodeTable WHERE RN_TECH_TYPE = @technoltypeid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Ќевозможно удалить технологический признак, так как '
							+ 'с ним был зарегистрирован дистрибутив.'  + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.PeriodRegTable WHERE REG_ID_TECH_TYPE = @technoltypeid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Ќевозможно удалить технологический признак, так как '
							+ 'имеютс€ записи в истории рег.узла с данным признаком.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.PeriodRegNewTable WHERE RNN_ID_TECH_TYPE = @technoltypeid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Ќевозможно удалить технологический признак, так как '
					+ 'имеютс€ записи о регистрации новых систем с данным признаком.'
		END
	--

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END