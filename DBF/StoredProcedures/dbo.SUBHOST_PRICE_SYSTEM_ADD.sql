USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SUBHOST_PRICE_SYSTEM_ADD]
	@SYS_ID	SMALLINT,
	@PT_ID	SMALLINT,
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@PRICE	MONEY,
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

		INSERT INTO dbo.SubhostPriceSystemTable
				(
					SPS_ID_SYSTEM, SPS_ID_TYPE, SPS_ID_HOST, 
					SPS_ID_PERIOD, SPS_PRICE, SPS_ACTIVE
				)
		VALUES(@SYS_ID, @PT_ID, @SH_ID, @PR_ID, @PRICE, @ACTIVE)

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
