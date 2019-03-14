USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:	4.05.2009
Описание:		Проверка на наличие статуса дистрибутива с заданным именем
				(выбор данных по имени)
*/

CREATE PROCEDURE [dbo].[DISTR_STATUS_CHECK_REG] 
	@dsname VARCHAR(100)  
AS
BEGIN
	SET NOCOUNT ON

	SELECT DS_ID
	FROM dbo.DistrStatusTable
	WHERE DS_REG = @dsname 

	SET NOCOUNT OFF
END








