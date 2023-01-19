USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SUBHOST_CHECK_LST_NAME]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SUBHOST_CHECK_LST_NAME]  AS SELECT 1')
GO

/*
Автор:			Денисов Алексей, Богдан Владимир
Дата создания:	25.08.2008, 3.06.2009
Описание:		Возвращает ID подхоста с указанным
				названием подхоста на РЦ.
*/

ALTER PROCEDURE [dbo].[SUBHOST_CHECK_LST_NAME]
	@subhostlstname VARCHAR(100)
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

		SELECT SH_ID
		FROM dbo.SubhostTable
		WHERE SH_LST_NAME = @subhostlstname

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SUBHOST_CHECK_LST_NAME] TO rl_subhost_w;
GO
