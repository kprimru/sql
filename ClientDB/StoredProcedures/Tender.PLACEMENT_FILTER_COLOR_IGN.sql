USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[PLACEMENT_FILTER_COLOR_IGN]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[PLACEMENT_FILTER_COLOR_IGN]  AS SELECT 1')
GO
ALTER PROCEDURE [Tender].[PLACEMENT_FILTER_COLOR_IGN]
	@ID_TENDER	UNIQUEIDENTIFIER
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

		DECLARE @IGN	BIT
		SELECT @IGN = COLOR_IGN
		FROM Tender.Placement
		WHERE ID_TENDER = @ID_TENDER

		SET @IGN = ISNULL(@IGN, 0)

		IF @IGN = 0
			SET @IGN = 1
		ELSE
			SET @IGN = 0

		UPDATE Tender.Placement
		SET COLOR_IGN = @IGN
		WHERE ID_TENDER = @ID_TENDER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[PLACEMENT_FILTER_COLOR_IGN] TO rl_tender_placement;
GO
