USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Выбор данных о блокированных
               записях со всеми данными
*/

ALTER PROCEDURE [dbo].[LOCK_GET]
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

		SELECT LC_TABLE, LC_DOC_ID, LC_LOGIN_NAME, LC_NT_USER, LC_HOST_NAME,
			   CONVERT(VARCHAR, LC_LOGIN_TIME, 113) AS LC_LOGIN_TIME, LC_SP_ID,
			   CONVERT(VARCHAR, LC_LOCK_TIME, 113) AS LC_LOCK_TIME
		FROM dbo.LockTable
		ORDER BY LC_TABLE, LC_DOC_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[LOCK_GET] TO rl_admin_lock_r;
GO