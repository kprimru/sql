USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[PRICE_VALIDATION_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[PRICE_VALIDATION_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[PRICE_VALIDATION_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	VARCHAR(4000),
	@SHORT	VARCHAR(200)
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

		UPDATE Purchase.PriceValidation
		SET PV_NAME		=	@NAME,
			PV_SHORT	=	@SHORT
		WHERE PV_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[PRICE_VALIDATION_UPDATE] TO rl_price_validation_u;
GO
