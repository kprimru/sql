USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PRICE_TYPE_SYSTEM_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PRICE_TYPE_SYSTEM_ADD]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[PRICE_TYPE_SYSTEM_ADD]
	@PT_ID	SMALLINT,
	@SST_ID	SMALLINT,
	@ACTIVE	BIT,
	@RETURN BIT = 1
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

		INSERT INTO dbo.PriceTypeSystemTable(PTS_ID_PT, PTS_ID_ST, PTS_ACTIVE)
			VALUES(@PT_ID, @SST_ID, @ACTIVE)

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
GRANT EXECUTE ON [dbo].[PRICE_TYPE_SYSTEM_ADD] TO rl_price_type_system_w;
GO
