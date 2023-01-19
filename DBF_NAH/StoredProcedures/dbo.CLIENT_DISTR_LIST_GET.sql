USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DISTR_LIST_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DISTR_LIST_GET]  AS SELECT 1')
GO

/*
Автор:         Денисов Алексей
Описание:      Выбрать данные о дистрибутиве клиента с указанным кодом
*/

ALTER PROCEDURE [dbo].[CLIENT_DISTR_LIST_GET]
	@cdid VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @cd TABLE
			(
				CD_ID INT
			)

		INSERT INTO @cd
			SELECT *
			FROM dbo.GET_TABLE_FROM_LIST(@cdid, ',')

		DECLARE @dislist VARCHAR(MAX)
		SET @dislist = ''

		SELECT @dislist = @dislist + DIS_STR + ','
		FROM dbo.ClientDistrView
		WHERE CD_ID IN
			(
				SELECT CD_ID
				FROM @cd
			)

		IF LEN(@dislist) > 0
			SET @dislist = LEFT(@dislist, LEN(@dislist) - 1)

		SELECT @dislist AS DIS_STR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_LIST_GET] TO rl_client_distr_r;
GO
