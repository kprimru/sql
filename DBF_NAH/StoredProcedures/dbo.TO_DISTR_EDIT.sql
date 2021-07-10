USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[TO_DISTR_EDIT]
	@tdid INT,
	@toid INT,
	@distrid INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.TODistrTable
	SET
		TD_ID_TO = @toid,
		TD_ID_DISTR = @distrid
	WHERE TD_ID = @tdid
END
GO
GRANT EXECUTE ON [dbo].[TO_DISTR_EDIT] TO rl_client_w;
GRANT EXECUTE ON [dbo].[TO_DISTR_EDIT] TO rl_to_distr_w;
GO