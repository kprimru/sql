USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[Period@Is Available]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[Period@Is Available]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[Period@Is Available]
	@Period_Id		UniqueIdentifier,
	@IsAvailable	Bit OUTPUT
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

		SET @IsAvailable = NULL;

		SELECT @IsAvailable = [IsAvailable]
		FROM [Price].[Periods=Available]
		WHERE [Period_Id] = @Period_Id;

		IF @IsAvailable IS NULL
			SET @IsAvailable = 0;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[Period@Is Available] TO rl_price_r;
GO
