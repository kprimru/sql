USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SUBHOST_NORM_SET]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@NORM	DECIMAL(8, 4)
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

		UPDATE dbo.SubhostNorm
		SET NORM = @NORM
		WHERE ID_PERIOD = @PR_ID
			--AND ID_SUBHOST = @SH_ID
			
		--IF @@ROWCOUNT = 0
		INSERT INTO dbo.SubhostNorm(ID_SUBHOST, ID_PERIOD, NORM)
			--VALUES(@SH_ID, @PR_ID, @NORM)
			SELECT SH_ID, @PR_ID, @NORM
			FROM dbo.SubhostTable
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.SubhostNorm
					WHERE ID_SUBHOST = SH_ID
						AND ID_PERIOD = @PR_ID
				)
				
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[SUBHOST_NORM_SET] TO rl_reg_node_report_r;
GRANT EXECUTE ON [dbo].[SUBHOST_NORM_SET] TO rl_reg_report_r;
GO