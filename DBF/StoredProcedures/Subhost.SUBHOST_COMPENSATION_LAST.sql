USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_COMPENSATION_LAST]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT
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

		DELETE
		FROM Subhost.SubhostCompensationTable
		WHERE SCP_ID_SUBHOST = @SH_ID AND SCP_ID_PERIOD = @PR_ID

		INSERT INTO Subhost.SubhostCompensationTable(
				SCP_ID_SUBHOST, SCP_ID_PERIOD, SCP_ID_SYSTEM, SCP_ID_TYPE,
				SCP_ID_NET, SCP_ID_TECH, SCP_DISTR, SCP_COMP, SCP_COMMENT
				)
			SELECT
				SCP_ID_SUBHOST, @PR_ID, SCP_ID_SYSTEM, SCP_ID_TYPE,
				SCP_ID_NET, SCP_ID_TECH, SCP_DISTR, SCP_COMP, SCP_COMMENT
			FROM Subhost.SubhostCompensationTable
			WHERE SCP_ID_SUBHOST = @SH_ID AND SCP_ID_PERIOD = dbo.PERIOD_PREV(@PR_ID)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Subhost].[SUBHOST_COMPENSATION_LAST] TO rl_subhost_calc;
GO