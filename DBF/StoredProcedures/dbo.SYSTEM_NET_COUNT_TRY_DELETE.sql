USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 23.09.2008
Описание:	  Возвращает 0, если кол-во станций 
               с указанным кодом моджно удалить. 
               -1 в противном случае
*/

CREATE PROCEDURE [dbo].[SYSTEM_NET_COUNT_TRY_DELETE] 
	@systemnetcountid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	-- добавлено 29.04.2009, В.Богдан
	IF EXISTS(SELECT * FROM dbo.RegNodeFullTable WHERE RN_ID_NET = @systemnetcountid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить количество сетевых станций, так как с ним был зарегистрирован дистрибутив. '
		END
	IF EXISTS(SELECT * FROM dbo.PeriodRegTable WHERE REG_ID_NET = @systemnetcountid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить количество станций, так как '
							+ 'имеются записи в истории рег.узла с данным количеством.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.PeriodRegNewTable WHERE RNN_ID_NET = @systemnetcountid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить количество станций, так как '
					+ 'имеются записи о регистрации новых систем с данным количеством.'
		END
	--
	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END



