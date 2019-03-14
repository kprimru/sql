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

CREATE PROCEDURE [dbo].[ADDRESS_TYPE_TRY_DELETE] 
	@addresstypeid TINYINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.ClientAddressTable WHERE CA_ID_TYPE = @addresstypeid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Данный тип адреса указан в одном или нескольких адресах. ' + 
							  'Удаление невозможно, пока выбранный тип адреса будет указан хотя ' +
							  'бы в одном адресе.'
		END

	SELECT @res AS RES, @txt AS TXT


	SET	NOCOUNT OFF
END






