USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 18.11.2008
Описание:	  Изменить данные о хосте с
               указанным кодом в справочнике
*/

ALTER PROCEDURE [dbo].[HOST_EDIT]
	@hostid SMALLINT,
	@hostname VARCHAR(250),
	@hostregname VARCHAR(20),
	@active BIT = 1
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

		UPDATE dbo.HostTable
		SET HST_NAME = @hostname,
			HST_REG_NAME = @hostregname,
			HST_ACTIVE = @active
		WHERE HST_ID = @hostid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[HOST_EDIT] TO rl_host_w;
GO