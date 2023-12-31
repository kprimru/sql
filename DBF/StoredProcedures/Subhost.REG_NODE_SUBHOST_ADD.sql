USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[REG_NODE_SUBHOST_ADD]
	@PR_ID		SMALLINT,
	@SH_ID		SMALLINT,
	@SYS_ID		SMALLINT,
	@SST_ID		SMALLINT,
	@SN_ID		SMALLINT,
	@TT_ID		SMALLINT,
	@DISTR		INT,
	@COMP		TINYINT,
	@COMMENT	VARCHAR(100),
	@SYS_OLD	SMALLINT,
	@SYS_NEW	SMALLINT,
	@NET_OLD	SMALLINT,
	@NET_NEW	SMALLINT,
	@TT_OLD		SMALLINT = NULL,
	@TT_NEW		SMALLINT = NULL
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

		INSERT INTO Subhost.RegNodeSubhostTable(
				RNS_ID_PERIOD, RNS_ID_HOST, RNS_ID_SYSTEM, RNS_ID_TYPE, RNS_ID_TECH, RNS_ID_NET,
				RNS_DISTR, RNS_COMP, RNS_COMMENT,
				RNS_ID_OLD_SYS, RNS_ID_NEW_SYS, RNS_ID_OLD_NET, RNS_ID_NEW_NET,
				RNS_ID_OLD_TECH, RNS_ID_NEW_TECH
				)
			VALUES(
				@PR_ID, @SH_ID, @SYS_ID, @SST_ID, @TT_ID, @SN_ID,
				@DISTR, @COMP, @COMMENT,
				@SYS_OLD, @SYS_NEW, @NET_OLD, @NET_NEW, @TT_OLD, @TT_NEW
				)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[REG_NODE_SUBHOST_ADD] TO rl_subhost_calc;
GO
