USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[MAIL_SEND]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[MAIL_SEND]  AS SELECT 1')
GO
ALTER PROCEDURE [Maintenance].[MAIL_SEND]
	@TEXT	NVARCHAR(MAX)
WITH EXECUTE AS OWNER
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

		EXEC msdb.dbo.sp_send_dbmail
					@profile_name	=	'SQLMail',
					@recipients		=	'denisov@bazis;blohin@bazis',
					@body			=	@TEXT,
					@subject		=	'Уведомление "Досье клиентов"',
					@query_result_header	=	0

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
