USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[EVENT_TYPE_SELECT]
	@FILTER	VARCHAR(100) = NULL,
	@HIDDEN	BIT = NULL
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

		SELECT EventTypeID, EventTypeName, EventTypeReport, EventTypeHide
		FROM dbo.EventTypeTable
		WHERE
			(EventTypeReport = 1 OR @HIDDEN = 1)
			AND
				(
					IS_MEMBER('rl_event_type_hide') = 1 AND EventTypeHide = 0 OR IS_MEMBER('rl_event_type_hide') = 0
				)
			AND(
				 @FILTER IS NULL
				OR EventTypeName LIKE @FILTER
				)
		ORDER BY EventTypeName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[EVENT_TYPE_SELECT] TO rl_event_type_r;
GO
