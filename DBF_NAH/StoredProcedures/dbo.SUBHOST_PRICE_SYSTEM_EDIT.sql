USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SUBHOST_PRICE_SYSTEM_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SUBHOST_PRICE_SYSTEM_EDIT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SUBHOST_PRICE_SYSTEM_EDIT]
	@SPS_ID	INT,
	@SYS_ID	SMALLINT,
	@PT_ID	SMALLINT,
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@PRICE	MONEY,
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

		UPDATE dbo.SubhostPriceSystemTable
		SET SPS_ID_SYSTEM = @SYS_ID,
			SPS_ID_TYPE = @PT_ID,
			SPS_ID_HOST = @SH_ID,
			SPS_ID_PERIOD = @PR_ID,
			SPS_PRICE = @PRICE,
			SPS_ACTIVE = @ACTIVE
		WHERE SPS_ID = @SPS_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
