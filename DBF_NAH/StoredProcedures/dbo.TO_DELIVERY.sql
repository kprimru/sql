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

ALTER PROCEDURE [dbo].[TO_DELIVERY]
	@toid INT,
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	-- перенести точку обслуживания к другому клиенту

	UPDATE dbo.TOTable
	SET TO_ID_CLIENT = @clientid
	WHERE TO_ID = @toid

	-- перенести дистрибутивы из ТО к клиенту
	UPDATE dbo.ClientDistrTable
	SET CD_ID_CLIENT = @clientid
	WHERE
		EXISTS
			(
				SELECT *
				FROM dbo.TODistrTable
				WHERE TD_ID_TO = @toid
					AND CD_ID_DISTR = TD_ID_DISTR
			)
END
GO
GRANT EXECUTE ON [dbo].[TO_DELIVERY] TO rl_to_w;
GO