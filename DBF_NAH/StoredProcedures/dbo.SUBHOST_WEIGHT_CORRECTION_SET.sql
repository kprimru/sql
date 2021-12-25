USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SUBHOST_WEIGHT_CORRECTION_SET]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@CORRECTION	DECIMAL(8, 4)
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

		UPDATE dbo.SubhostWeightCorrection
		SET CORRECTION = @CORRECTION
		WHERE ID_PERIOD = @PR_ID
			AND ID_SUBHOST = @SH_ID

		IF @@ROWCOUNT = 0
			INSERT INTO dbo.SubhostWeightCorrection(ID_SUBHOST, ID_PERIOD, CORRECTION)
				VALUES(@SH_ID, @PR_ID, @CORRECTION)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
