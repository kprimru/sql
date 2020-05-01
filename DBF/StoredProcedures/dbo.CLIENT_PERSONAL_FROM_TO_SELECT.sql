USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			коллектив авторов
Дата создания:	26.02.2009
Описание:		Получить всех сотрудников
					из всех ТО клиента
*/

ALTER PROCEDURE [dbo].[CLIENT_PERSONAL_FROM_TO_SELECT] 
	@clientid INT
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
		SELECT DISTINCT	TP_ID, TP_SURNAME, TP_NAME, TP_OTCH, POS_NAME, RP_NAME, TO_NAME
			FROM		dbo.TOPersonalView
			WHERE		TO_ID_CLIENT=@clientid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_FROM_TO_SELECT] TO rl_client_personal_w;
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_FROM_TO_SELECT] TO rl_client_w;
GO