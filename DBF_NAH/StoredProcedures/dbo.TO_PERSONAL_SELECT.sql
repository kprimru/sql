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

ALTER PROCEDURE [dbo].[TO_PERSONAL_SELECT]
	@toid INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT
			TP_ID, (TP_SURNAME + ' ' + TP_NAME + ' ' + TP_OTCH) AS TP_FIO,
			TP_PHONE, POS_NAME, RP_NAME, TP_LAST
	FROM dbo.TOPersonalView
	WHERE TP_ID_TO = @toid
	ORDER BY RP_NAME

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[TO_PERSONAL_SELECT] TO rl_client_r;
GRANT EXECUTE ON [dbo].[TO_PERSONAL_SELECT] TO rl_to_personal_r;
GO