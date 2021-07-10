USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  Выбрать даанные о сотрудниках указанной ТО.
*/

ALTER PROCEDURE [dbo].[TO_PERSONAL_DELETE]
	@personalid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.TOPersonalTable
	WHERE TP_ID = @personalid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[TO_PERSONAL_DELETE] TO rl_client_d;
GRANT EXECUTE ON [dbo].[TO_PERSONAL_DELETE] TO rl_to_personal_d;
GO