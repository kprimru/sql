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

ALTER PROCEDURE [dbo].[TO_DISTR_DELETE]
	@tdid INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM dbo.TODistrTable WHERE TD_ID = @tdid
END
GO
GRANT EXECUTE ON [dbo].[TO_DISTR_DELETE] TO rl_client_d;
GRANT EXECUTE ON [dbo].[TO_DISTR_DELETE] TO rl_to_distr_d;
GO