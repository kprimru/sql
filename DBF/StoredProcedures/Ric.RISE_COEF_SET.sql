USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Ric].[RISE_COEF_SET]
	@PR_ID	SMALLINT,
	@VALUE	DECIMAL(8, 4)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Ric.RiseCoef
	SET RC_VALUE = @VALUE
	WHERE RC_ID_PERIOD = @PR_ID

	IF @@ROWCOUNT = 0
		INSERT INTO Ric.RiseCoef(RC_ID_PERIOD, RC_VALUE)
			SELECT @PR_ID, @VALUE
END
