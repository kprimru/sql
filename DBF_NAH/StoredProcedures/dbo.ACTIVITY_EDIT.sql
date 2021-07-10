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

ALTER PROCEDURE [dbo].[ACTIVITY_EDIT]
	@id SMALLINT,
	@name VARCHAR(100),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.ActivityTable
	SET AC_NAME = @name,
		AC_ACTIVE = @active
	WHERE AC_ID = @id

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[ACTIVITY_EDIT] TO rl_activity_w;
GO