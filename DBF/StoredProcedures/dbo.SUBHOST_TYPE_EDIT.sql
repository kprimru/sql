USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SUBHOST_TYPE_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SUBHOST_TYPE_EDIT]  AS SELECT 1')
GO



/*
Автор:		  Проценко Сергей
Описание:
*/

ALTER PROCEDURE [dbo].[SUBHOST_TYPE_EDIT]
	@subhostId TinyInt,
	@subhosCode VARCHAR(50),
	@subhosName VARCHAR(100),
	@subhosActive BIT = 1
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

		UPDATE [dbo].[SubhostType]
		SET [ST_CODE] = @subhosCode,
			[ST_NAME] = @subhosName,
			[ST_ACTIVE] = @subhosActive
		WHERE [ST_ID] = @subhostId

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SUBHOST_TYPE_EDIT] TO rl_subhost_type_w;
GO
