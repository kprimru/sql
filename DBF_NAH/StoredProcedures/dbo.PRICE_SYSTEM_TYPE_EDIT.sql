USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PRICE_SYSTEM_TYPE_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PRICE_SYSTEM_TYPE_EDIT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[PRICE_SYSTEM_TYPE_EDIT]
	@PST_ID	INT,
	@SYS_ID	SMALLINT,
	@PT_ID	SMALLINT,
	@SST_ID	SMALLINT,
	@COEF	DECIMAL(8, 4),
	@FIXED	MONEY,
	@DISC	DECIMAL(8, 4),
	@START	SMALLDATETIME,
	@END	SMALLDATETIME,
	@ACTIVE	BIT
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

		UPDATE dbo.PriceSystemType
		SET PST_ID_SYSTEM = @SYS_ID,
			PST_ID_PRICE = @PT_ID,
			PST_ID_TYPE = @SST_ID,
			PST_COEF = @COEF,
			PST_FIXED = @FIXED,
			PST_DISCOUNT = @DISC,
			PST_START = @START,
			PST_END = @END,
			PST_ACTIVE = @ACTIVE
		WHERE PST_ID = @PST_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PRICE_SYSTEM_TYPE_EDIT] TO rl_price_system_type_w;
GO
