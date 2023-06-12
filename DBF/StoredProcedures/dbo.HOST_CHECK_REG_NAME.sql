USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[HOST_CHECK_REG_NAME]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[HOST_CHECK_REG_NAME]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Дата создания: 18.11.2008
Описание:	  Возвращает ID хоста с указанным
               названием рег.
*/

ALTER PROCEDURE [dbo].[HOST_CHECK_REG_NAME]
	@hostregname VARCHAR(20)
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

		SELECT HST_ID
		FROM dbo.HostTable
		WHERE HST_REG_NAME = @hostregname

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[HOST_CHECK_REG_NAME] TO rl_host_w;
GO
