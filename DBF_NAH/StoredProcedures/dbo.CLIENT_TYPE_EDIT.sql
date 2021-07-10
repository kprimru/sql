USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_TYPE_EDIT]
	@id SMALLINT,
	@name VARCHAR(100),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.ClientTypeTable
	SET CLT_NAME = @name,
		CLT_ACTIVE = @active
	WHERE CLT_ID = @id

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_TYPE_EDIT] TO rl_client_type_w;
GO