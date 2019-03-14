USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Ric].[GROW_COEF_SAVE]
	@QR_ID	SMALLINT,
	@VALUE	DECIMAL(10, 4)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Ric.DepthCoef
	SET DC_VALUE = @VALUE
	WHERE DC_ID_QUARTER = @QR_ID
	
	IF @@ROWCOUNT = 0
		INSERT INTO Ric.DepthCoef(DC_ID_QUARTER, DC_VALUE)
			VALUES(@QR_ID, @VALUE)
END
