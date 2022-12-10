USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей (update: Проценко Сергей)
Описание:
*/

ALTER PROCEDURE [dbo].[SUBHOST_SELECT]
    @active BIT = NULL
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

		SELECT	[SH_ID],
				[SH_FULL_NAME],
				[SH_SHORT_NAME],
				[SH_LST_NAME],
				[SH_ORDER],
				[SH_ACTIVE],
				[SH_ID_TYPE],
				[ST_NAME] AS SUBHOST_TYPE_NAME
		FROM [dbo].[SubhostTable] AS STable
		LEFT JOIN [dbo].[SubhostType] AS SType ON [Stable].[SH_ID_TYPE] = [SType].[ST_ID]
		WHERE [SH_ACTIVE] = ISNULL(@active, [SH_ACTIVE])
		ORDER BY [SH_ORDER]


		SELECT [SH_ID], [SH_FULL_NAME], [SH_SHORT_NAME], [SH_LST_NAME], [SH_ORDER], [SH_ACTIVE], [SH_ID_TYPE]
		FROM [dbo].[SubhostTable]
		WHERE [SH_ACTIVE] = ISNULL(@active, [SH_ACTIVE])
		ORDER BY [SH_ORDER]

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SUBHOST_SELECT] TO rl_subhost_r;
GO
