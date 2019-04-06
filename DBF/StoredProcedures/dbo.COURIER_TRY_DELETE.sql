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
CREATE PROCEDURE [dbo].[COURIER_TRY_DELETE] 
	@courierid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''
	
	-- изменено 30.04.2009, В.Богдан
	
	/*IF EXISTS(SELECT * FROM dbo.CLientTable WHERE CL_ID_COUR = @courierid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + 'Данный сервис-инженер указан у одного или нескольких ТО. ' + 
						  'Удаление невозможно, пока выбранный сервис-инженер будет указан хотя ' +
						  'бы у одной ТО.'
	  END
	*/
	-- заменено на:
	IF EXISTS(SELECT * FROM dbo.TOTable WHERE TO_ID_COUR = @courierid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Данный сервис-инженер указан у одного или нескольких ТО. ' + 
							  'Удаление невозможно, пока выбранный сервис-инженер будет указан хотя ' +
							  'бы у одной ТО.'
		END
	--

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF
END