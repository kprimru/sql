USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:         Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_DISTR_DELIVERY]
	@id VARCHAR(MAX),
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @list TABLE
		(
			ID INT
		)

	INSERT INTO @list
		SELECT *
		FROM dbo.GET_TABLE_FROM_LIST(@id, ',')

	INSERT INTO dbo.DistrDeliveryHistoryTable
		(DDH_ID_DISTR, DDH_ID_OLD_CLIENT, DDH_ID_NEW_CLIENT)
		SELECT CD_ID_DISTR, CD_ID_CLIENT, @clientid
		FROM dbo.ClientDistrTable
		WHERE CD_ID IN
			(
				SELECT ID
				FROM @list
			)


	UPDATE dbo.ClientDistrTable
	SET CD_ID_CLIENT = @clientid
	WHERE CD_ID IN
		(
			SELECT ID
			FROM @list
		)

	--удалить из ТО этот дистрибутив

	DELETE
	FROM dbo.TODistrTable
	WHERE TD_ID_DISTR IN
		(
			SELECT CD_ID_DISTR
			FROM  dbo.ClientDistrTable
			WHERE CD_ID IN
				(
					SELECT ID
					FROM @list
				)
		)

	IF (SELECT COUNT(*) FROM dbo.TOTable WHERE TO_ID_CLIENT = @clientid) = 1
		BEGIN
			INSERT INTO dbo.TODistrTable (TD_ID_TO, TD_ID_DISTR)
			SELECT
				(
					SELECT TO_ID
					FROM dbo.TOTable
					WHERE TO_ID_CLIENT = @clientid
				), CD_ID_DISTR
			FROM  dbo.ClientDistrTable
			WHERE CD_ID IN
				(
					SELECT ID
					FROM @list
				)

		END

	SET NOCOUNT OFF
END







GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_DELIVERY] TO rl_client_distr_w;
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_DELIVERY] TO rl_client_w;
GO