USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SUBHOST_TYPE_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SUBHOST_TYPE_GET]  AS SELECT 1')
GO



/*
Автор:		  Проценко Сергей
Описание:
*/

ALTER PROCEDURE [dbo].[SUBHOST_TYPE_GET]
	@subhostId int
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

		SELECT [ST_ID], [ST_CODE], [ST_NAME], [ST_ACTIVE]
		FROM [dbo].[SubhostType]
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
GRANT EXECUTE ON [dbo].[SUBHOST_TYPE_GET] TO rl_subhost_type_r;
GO
