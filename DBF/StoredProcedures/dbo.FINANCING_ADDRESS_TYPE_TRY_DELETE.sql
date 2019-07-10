USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
јвтор:			ƒенисов јлексей 
ƒата создани€:	3 July 2009
ќписание:		¬озвращает 0, если тип адреса в фин. документе 
				с указанным кодом можно удалить из 
				справочника, 
				-1 в противном случае
*/
CREATE PROCEDURE [dbo].[FINANCING_ADDRESS_TYPE_TRY_DELETE] 
	@fatid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

/*
	IF EXISTS(SELECT * FROM dbo.ClientTable WHERE CL_ID_FIN = @financingid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + 'ƒанный тип финансировани€ указан у одного или нескольких клиентов. ' + 
						  '”даление невозможно, пока выбранный тип финансировани€ будет указан хот€ ' +
						  'бы у одного клиента.'
	  END 
*/

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF
END