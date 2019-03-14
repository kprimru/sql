USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:         Денисов Алексей
Описание:      Выбрать данные о дистрибутиве клиента с указанным кодом
*/

CREATE PROCEDURE [dbo].[CLIENT_DISTR_LIST_GET]
	@cdid VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @cd TABLE
		(
			CD_ID INT
		)

	INSERT INTO @cd 
		SELECT *
		FROM dbo.GET_TABLE_FROM_LIST(@cdid, ',')

	DECLARE @dislist VARCHAR(MAX)
	SET @dislist = ''

	SELECT @dislist = @dislist + DIS_STR + ','
	FROM dbo.ClientDistrView
	WHERE CD_ID IN
		(
			SELECT CD_ID
			FROM @cd
		)

	IF LEN(@dislist) > 0
		SET @dislist = LEFT(@dislist, LEN(@dislist) - 1)
	
	SELECT @dislist AS DIS_STR

	SET NOCOUNT OFF
END









