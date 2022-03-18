USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SUBHOST_VKSP_SET]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@VKSP	INT
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

		UPDATE dbo.SubhostVKSP
		SET VKSP = @VKSP
		WHERE ID_PERIOD = @PR_ID
			AND ID_SUBHOST = @SH_ID

		IF @@ROWCOUNT = 0
			INSERT INTO dbo.SubhostVKSP(ID_SUBHOST, ID_PERIOD, VKSP)
				VALUES(@SH_ID, @PR_ID, @VKSP)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SUBHOST_VKSP_SET] TO rl_reg_node_report_r;
GRANT EXECUTE ON [dbo].[SUBHOST_VKSP_SET] TO rl_reg_report_r;
GO
