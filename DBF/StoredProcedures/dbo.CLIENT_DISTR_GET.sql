USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:         Денисов Алексей
Описание:      Выбрать данные о дистрибутиве клиента с указанным кодом
*/

ALTER PROCEDURE [dbo].[CLIENT_DISTR_GET]
	@clientdistrid INT
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

		SELECT
			CD_ID, DIS_ID, DIS_STR, CD_REG_DATE, DSS_NAME, DSS_ID
		FROM dbo.ClientDistrView
		WHERE CD_ID = @clientdistrid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_GET] TO rl_client_distr_r;
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_GET] TO rl_client_r;
GO
