USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:		  Проценко Сергей
Описание:
*/

ALTER PROCEDURE [dbo].[SUBHOST_TYPE_SELECT]
  @subhostActive BIT = NULL

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

		SELECT [ST_ID], [ST_CODE], [ST_NAME]
		FROM [dbo].[SubhostType]
		WHERE [ST_ACTIVE] = ISNULL(@subhostActive, [ST_ACTIVE])
		ORDER BY [ST_NAME] DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SUBHOST_TYPE_SELECT] TO rl_subhost_type_r;
GO
