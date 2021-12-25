USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PRICE_SYSTEM_TYPE_ADD]
	@SYS_ID	SMALLINT,
	@PT_ID	SMALLINT,
	@SST_ID	SMALLINT,
	@COEF	DECIMAL(8, 4),
	@FIXED	MONEY,
	@DISC	DECIMAL(8, 4),
	@START	SMALLDATETIME,
	@END	SMALLDATETIME,
	@ACTIVE	BIT,
	@RETURN	BIT = 1
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

		INSERT INTO dbo.PriceSystemType(PST_ID_SYSTEM, PST_ID_PRICE, PST_ID_TYPE, PST_COEF, PST_FIXED, PST_DISCOUNT, PST_START, PST_END, PST_ACTIVE)
			VALUES(@SYS_ID, @PT_ID, @SST_ID, @COEF, @FIXED, @DISC, @START, @END, @ACTIVE)

		IF @RETURN = 1
			SELECT SCOPE_IDENTITY() AS NEW_IDEN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PRICE_SYSTEM_TYPE_ADD] TO rl_price_system_type_r;
GO
