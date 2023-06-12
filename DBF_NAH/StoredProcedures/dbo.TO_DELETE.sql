USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TO_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[TO_DELETE]  AS SELECT 1')
GO

/*
Автор:			Денисов Алексей
Описание:		Выбор всех точек обслуживания указанного клиента
*/

ALTER PROCEDURE [dbo].[TO_DELETE]
	@toid INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DELETE FROM dbo.TOAddressTable WHERE TA_ID_TO = @toid
		DELETE FROM dbo.TOTable WHERE TO_ID = @toid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[TO_DELETE] TO rl_client_d;
GRANT EXECUTE ON [dbo].[TO_DELETE] TO rl_to_d;
GO
