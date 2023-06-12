USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[SUBHOST_COMPENSATION_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[SUBHOST_COMPENSATION_ADD]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[SUBHOST_COMPENSATION_ADD]
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

		INSERT INTO Subhost.SubhostCompensationTable(
				SCP_ID_SUBHOST, SCP_ID_PERIOD, SCP_ID_SYSTEM, SCP_ID_TYPE,
				SCP_ID_NET, SCP_ID_TECH, SCP_DISTR, SCP_COMP, SCP_COMMENT
			)
			VALUES (@SH_ID, @PR_ID, @SYS_ID, @SST_ID, @SN_ID, @TT_ID, @DISTR, @COMP, @COMMENT)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_COMPENSATION_ADD] TO rl_subhost_calc;
GO
