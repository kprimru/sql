USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_TYPE_WEIGHT_EDIT]
	@STW_ID	INT,
	@SYS_ID	SMALLINT,
	@SST_ID	SMALLINT,
	@WEIGHT	SMALLINT,
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

		UPDATE dbo.SystemTypeWeightTable
		SET STW_ID_SYSTEM = @SYS_ID,
			STW_ID_TYPE = @SST_ID,
			STW_WEIGHT = @WEIGHT,
			STW_ACTIVE = @ACTIVE
		WHERE STW_ID = @STW_ID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[SYSTEM_TYPE_WEIGHT_EDIT] TO rl_system_type_weight_w;
GO