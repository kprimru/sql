USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[PERIOD_ACTIVE_YEAR]
	@ID			UNIQUEIDENTIFIER
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

		DECLARE @Year Int;
		DECLARE @Active Bit;

		SELECT
			@Year = DatePart(Year, START),
			@Active = ACTIVE
		FROM Common.Period
		WHERE	ID			=	@ID

		UPDATE	Common.Period
		SET		ACTIVE		=	CASE @Active WHEN 1 THEN 0 ELSE 1 END
		WHERE	DatePart(Year, START) = @Year

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Common].[PERIOD_ACTIVE_YEAR] TO rl_period_u;
GO
