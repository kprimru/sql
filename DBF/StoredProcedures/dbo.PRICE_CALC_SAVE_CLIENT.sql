USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRICE_CALC_SAVE_CLIENT]
	@PR_ID	SMALLINT,
	@SYS_ID	SMALLINT,
	@PRICE	MONEY
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

		SET @PRICE = ISNULL(@PRICE, 0)

		UPDATE dbo.PriceSystemTable
		SET PS_PRICE = @PRICE
		WHERE PS_ID_PERIOD = @PR_ID
			AND PS_ID_SYSTEM = @SYS_ID
			AND PS_ID_TYPE = 1

		IF @@ROWCOUNT = 0
			INSERT INTO dbo.PriceSystemTable(PS_ID_PERIOD, PS_ID_SYSTEM, PS_ID_TYPE, PS_PRICE)
				VALUES(@PR_ID, @SYS_ID, 1, @PRICE)
				
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
