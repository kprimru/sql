USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SUBHOST_WEIGHT_CORRECTION_SET]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@CORRECTION	DECIMAL(8, 4)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.SubhostWeightCorrection
	SET CORRECTION = @CORRECTION
	WHERE ID_PERIOD = @PR_ID
		AND ID_SUBHOST = @SH_ID
		
	IF @@ROWCOUNT = 0
		INSERT INTO dbo.SubhostWeightCorrection(ID_SUBHOST, ID_PERIOD, CORRECTION)
			VALUES(@SH_ID, @PR_ID, @CORRECTION)
END
