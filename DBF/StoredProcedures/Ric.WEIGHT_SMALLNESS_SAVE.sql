USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Ric].[WEIGHT_SMALLNESS_SAVE]
	@QR_ID	SMALLINT,
	@VALUE	DECIMAL(10, 4)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Ric.WeightSmallness
	SET WS_VALUE = @VALUE
	WHERE WS_ID_QUARTER = @QR_ID

	IF @@ROWCOUNT = 0
		INSERT INTO Ric.WeightSmallness(WS_ID_QUARTER, WS_VALUE)
			SELECT @QR_ID, @VALUE
END
