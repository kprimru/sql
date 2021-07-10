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

ALTER PROCEDURE [dbo].[TO_DISTR_TRY_DELETE]
	@tdid INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	SELECT @res AS RES, @txt AS TXT
END
GO
GRANT EXECUTE ON [dbo].[TO_DISTR_TRY_DELETE] TO rl_client_d;
GRANT EXECUTE ON [dbo].[TO_DISTR_TRY_DELETE] TO rl_to_distr_d;
GO