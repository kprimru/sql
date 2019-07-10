USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
јвтор:		  ƒенисов јлексей
ќписание:	  ¬озвращает 0, если тип договора с 
                указанным кодом можно удалить 
                (на нее не ссылаетс€ ни один 
                договор клиента), 
                -1 в противном случае
*/

CREATE PROCEDURE [dbo].[CONTRACT_TYPE_TRY_DELETE] 
	@contracttypeid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.ContractTable WHERE CO_ID_TYPE = @contracttypeid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + 'ƒанный тип указан у одного или нескольких договоров. ' + 
						  '”даление невозможно, пока выбранный тип будет указан хот€ ' +
						  'бы в одном договоре.'
	  END

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF
END