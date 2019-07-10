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

CREATE PROCEDURE [dbo].[BANK_TRY_DELETE] 
	@bankid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.ClientTable WHERE CL_ID_BANK = @bankid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Данный банк указан у одного или нескольких клиентов. ' + 
							  'Удаление невозможно, пока выбранный банк будет указан хотя ' +
							  'бы у одного клиента.' + CHAR(13)
		END

	-- добавлено 30.04.2009, В.Богдан
	IF EXISTS(SELECT * FROM dbo.OrganizationTable WHERE ORG_ID_BANK = @bankid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Данный банк указан у одной или нескольких обслуживающих организаций. ' + 
							  'Удаление невозможно, пока выбранный банк будет указан хотя ' +
							  'бы у одной обслуживающей организации.' + CHAR(13)
		END
	--

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END

