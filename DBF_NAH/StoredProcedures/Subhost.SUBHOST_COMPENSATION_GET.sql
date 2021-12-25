USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_COMPENSATION_GET]
	@SCP_ID	INT
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

		SELECT
			PR_ID, PR_NAME, SYS_ID, SYS_SHORT_NAME, SCP_DISTR, SCP_COMP,
			SST_ID, SST_CAPTION, SN_ID, SN_NAME,
			SH_ID, SH_SHORT_NAME, SCP_COMMENT
		FROM
			Subhost.SubhostCompensationTable INNER JOIN
			dbo.SubhostTable ON SH_ID = SCP_ID_SUBHOST INNER JOIN
			dbo.PeriodTable ON PR_ID = SCP_ID_PERIOD INNER JOIN
			dbo.SystemTable ON SYS_ID = SCP_ID_SYSTEM INNER JOIN
			dbo.SystemTypeTable ON SST_ID = SCP_ID_TYPE INNER JOIN
			dbo.SystemNetTable ON SN_ID = SCP_ID_NET
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
GRANT EXECUTE ON [Subhost].[SUBHOST_COMPENSATION_GET] TO rl_subhost_calc;
GO
