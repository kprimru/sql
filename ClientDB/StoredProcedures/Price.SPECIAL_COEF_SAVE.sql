USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[SPECIAL_COEF_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[SPECIAL_COEF_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[SPECIAL_COEF_SAVE]
	@System_Id		Int,
	@DistrType_Id	Int,
	@SystemType_Id	Int,
	@PERIOD			UniqueIdentifier,
	@Coef			Decimal(8, 4),
	@Round			SmallInt
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Date			SmallDateTime;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT @Date = [START]
		FROM [Common].[Period]
		WHERE [ID] = @PERIOD;

		IF @SystemType_Id IS NOT NULL BEGIN
			UPDATE [Price].[Coef:Special]
			SET [Coef]	= @Coef,
				[Round]	= @Round
			WHERE [System_Id] = @System_Id
				AND [DistrType_Id] = @DistrType_Id
				AND [SystemType_Id] = @SystemType_Id
				AND [Date] = @Date;

			IF @@RowCount < 1
				INSERT INTO [Price].[Coef:Special]([System_Id], [DistrType_Id], [SystemType_Id], [Date], [Coef], [Round])
				SELECT @System_Id, @DistrType_Id, @SystemType_Id, @Date, @Coef, @Round;
		END ELSE BEGIN
			UPDATE [Price].[Coef:Special:Common]
			SET [Coef]	= @Coef,
				[Round]	= @Round
			WHERE [System_Id] = @System_Id
				AND [DistrType_Id] = @DistrType_Id
				AND [Date] = @Date;

			IF @@RowCount < 1
				INSERT INTO [Price].[Coef:Special:Common]([System_Id], [DistrType_Id], [Date], [Coef], [Round])
				SELECT @System_Id, @DistrType_Id, @Date, @Coef, @Round;
		END;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[SPECIAL_COEF_SAVE] TO rl_price_import;
GO
