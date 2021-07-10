USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[GOOD_EDIT]
	@id SMALLINT,
	@name VARCHAR(150),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.GoodTable
	SET GD_NAME = @name,
		GD_ACTIVE = @active
	WHERE GD_ID = @id
END


GO
GRANT EXECUTE ON [dbo].[GOOD_EDIT] TO rl_good_w;
GO