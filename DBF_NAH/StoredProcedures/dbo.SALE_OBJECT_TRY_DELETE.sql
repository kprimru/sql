USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[SALE_OBJECT_TRY_DELETE]
	@soid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	-- добавлено 29.04.2009, В.Богдан
	IF EXISTS(SELECT * FROM dbo.SystemTable WHERE SYS_ID_SO = @soid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить объект продажи, так как существуют относящиеся к нему системы. '
		END
	--

	SELECT @res AS RES, @txt AS TXT
END




GO
GRANT EXECUTE ON [dbo].[SALE_OBJECT_TRY_DELETE] TO rl_sale_object_d;
GO