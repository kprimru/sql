USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DISTR_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DISTR_EDIT]  AS SELECT 1')
GO


/*
Автор:         Денисов Алексей
Описание:      Изменить данные о дистрибутиве клиента
*/

ALTER PROCEDURE [dbo].[CLIENT_DISTR_EDIT]
	@id INT,
	@distrid INT,
	@regdate SMALLDATETIME,
	@systemserviceid SMALLINT
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

		UPDATE dbo.ClientDistrTable
		SET CD_ID_DISTR = @distrid,
			CD_REG_DATE = @regdate,
			CD_ID_SERVICE = @systemserviceid
		WHERE CD_ID = @id

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_EDIT] TO rl_client_distr_w;
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_EDIT] TO rl_client_w;
GO
