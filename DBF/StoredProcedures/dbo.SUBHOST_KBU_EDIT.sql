USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SUBHOST_KBU_EDIT]
	@SK_ID	INT,
	@SH_ID	SMALLINT,
	@SYS_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@KBU	DECIMAL(8, 4),
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

		UPDATE dbo.SubhostKBUTable
		SET SK_ID_HOST = @SH_ID,
			SK_ID_SYSTEM = @SYS_ID,
			SK_ID_PERIOD = @PR_ID,
			SK_KBU = @KBU,
			SK_ACTIVE = @ACTIVE
		WHERE SK_ID = @SK_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SUBHOST_KBU_EDIT] TO rl_subhost_kbu_w;
GO
