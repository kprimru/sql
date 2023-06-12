USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SUBHOST_POLKA_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SUBHOST_POLKA_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SUBHOST_POLKA_GET]
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

		SELECT POLKA
		FROM dbo.SubhostPOLKA
		WHERE ID_PERIOD = @PR_ID
			AND ID_SUBHOST = @SH_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SUBHOST_POLKA_GET] TO rl_reg_node_report_r;
GRANT EXECUTE ON [dbo].[SUBHOST_POLKA_GET] TO rl_reg_report_r;
GO
