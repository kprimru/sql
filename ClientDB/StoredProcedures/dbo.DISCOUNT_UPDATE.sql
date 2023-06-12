USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DISCOUNT_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DISCOUNT_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[DISCOUNT_UPDATE]
	@ID	INT,
	@VALUE	VARCHAR(100),
	@ORDER	INT
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

		UPDATE dbo.DiscountTable
		SET DiscountValue = @VALUE,
			DiscountOrder = @ORDER
		WHERE DiscountID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISCOUNT_UPDATE] TO rl_discount_u;
GO
