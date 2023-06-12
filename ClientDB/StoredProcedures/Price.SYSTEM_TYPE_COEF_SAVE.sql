﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[SYSTEM_TYPE_COEF_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[SYSTEM_TYPE_COEF_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[SYSTEM_TYPE_COEF_SAVE]
	@TYPE		Int,
	@PERIOD		UniqueIdentifier,
	@COEF		Decimal(8, 4),
	@RND		SmallInt
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

		UPDATE [Price].[SystemType:Coef]
		SET [Coef]	= @COEF,
			[Round]	= @RND
		WHERE [SystemType_Id] = @TYPE
			AND [Date] = @Date;

		IF @@RowCount < 1
			INSERT INTO [Price].[SystemType:Coef]([SystemType_Id], [Date], [Coef], [Round])
			SELECT @TYPE, @Date, @COEF, @RND;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[SYSTEM_TYPE_COEF_SAVE] TO rl_price_import;
GO
