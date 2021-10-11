USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_COMPENSATION_EDIT]
	@SCP_ID	INT,
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@SYS_ID	SMALLINT,
	@SST_ID	SMALLINT,
	@SN_ID	SMALLINT,
	@TT_ID	SMALLINT,
	@DISTR	INT,
	@COMP	TINYINT,
	@COMMENT	VARCHAR(100)
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

		UPDATE Subhost.SubhostCompensationTable
		SET SCP_ID_SUBHOST = @SH_ID,
			SCP_ID_PERIOD = @PR_ID,
			SCP_ID_SYSTEM = @SYS_ID,
			SCP_ID_NET = @SN_ID,
			SCP_ID_TYPE = @SST_ID,
			SCP_ID_TECH = @TT_ID,
			SCP_DISTR = @DISTR,
			SCP_COMP = @COMP,
			SCP_COMMENT = @COMMENT
		WHERE SCP_ID = @SCP_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_COMPENSATION_EDIT] TO rl_subhost_calc;
GO
