USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SUBHOST_POLKA_SET]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@POLKA	DECIMAL(8, 4)
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

		UPDATE dbo.SubhostPolka
		SET POLKA = @POLKA
		WHERE ID_PERIOD = @PR_ID
			--AND ID_SUBHOST = @SH_ID
			
		--IF @@ROWCOUNT = 0
		INSERT INTO dbo.SubhostPolka(ID_SUBHOST, ID_PERIOD, POLKA)
				--VALUES(@SH_ID, @PR_ID, @POLKA)
			SELECT SH_ID, @PR_ID, @POLKA
			FROM dbo.SubhostTable
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.SubhostPolka
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
GRANT EXECUTE ON [dbo].[SUBHOST_POLKA_SET] TO rl_reg_node_report_r;
GRANT EXECUTE ON [dbo].[SUBHOST_POLKA_SET] TO rl_reg_report_r;
GO