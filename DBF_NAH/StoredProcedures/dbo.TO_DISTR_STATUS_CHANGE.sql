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

ALTER PROCEDURE [dbo].[TO_DISTR_STATUS_CHANGE]
	@tdid VARCHAR(MAX),
	@status SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @list TABLE
		(
			TD_ID INT
		)

	INSERT INTO @list
		SELECT *
		FROM dbo.GET_TABLE_FROM_LIST(@tdid, ',')

	UPDATE dbo.ClientDistrTable
	SET
		CD_ID_SERVICE = @STATUS
	WHERE CD_ID_DISTR IN
		(
			SELECT TD_ID_DISTR
			FROM
				@list a
				INNER JOIN dbo.TODistrTable b ON a.TD_ID = b.TD_ID
		)
END

GO
GRANT EXECUTE ON [dbo].[TO_DISTR_STATUS_CHANGE] TO rl_client_distr_w;
GO