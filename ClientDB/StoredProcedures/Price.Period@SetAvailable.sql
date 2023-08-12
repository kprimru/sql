USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[Period@SetAvailable]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[Period@SetAvailable]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Price].[Period@SetAvailable]
	@Period_Id		UniqueIdentifier,
	@IsAvailable	Bit
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

		MERGE [Price].[Periods=Available] AS PA
		USING
		(
			SELECT
				[Period_Id] = @Period_Id,
				[IsAvailable] = @IsAvailable
		) AS U ON PA.[Period_Id] = U.[Period_Id]
		WHEN MATCHED THEN UPDATE SET [IsAvailable] = U.[IsAvailable]
		WHEN NOT MATCHED THEN
			INSERT([Period_Id], [IsAvailable])
			VALUES(U.[Period_Id], U.[IsAvailable]);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[Period@SetAvailable] TO rl_price_import;
GO
