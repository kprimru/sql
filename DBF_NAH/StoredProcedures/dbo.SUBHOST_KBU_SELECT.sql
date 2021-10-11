USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SUBHOST_KBU_SELECT]
	@ACTIVE BIT = NULL
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

		SELECT SK_ID, SH_ID, SH_SHORT_NAME, SYS_ID, SYS_SHORT_NAME, PR_ID, PR_NAME, SK_KBU, SK_ACTIVE
		FROM
			dbo.SubhostKBUTable INNER JOIN
			dbo.SubhostTable ON SK_ID_HOST = SH_ID INNER JOIN
			dbo.SystemTable ON SYS_ID = SK_ID_SYSTEM INNER JOIN
			dbo.PeriodTable ON PR_ID = SK_ID_PERIOD
		WHERE SK_ACTIVE = ISNULL(@ACTIVE, SK_ACTIVE)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SUBHOST_KBU_SELECT] TO rl_subhost_kbu_r;
GO
