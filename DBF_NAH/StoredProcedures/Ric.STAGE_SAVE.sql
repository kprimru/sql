USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[STAGE_SAVE]
	@PR_ID	SMALLINT,
	@VALUE	DECIMAL(10, 4)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @QR_ID	SMALLINT

	SET @QR_ID = dbo.PeriodQuarter(@PR_ID)

	UPDATE Ric.Stage
	SET ST_VALUE = @VALUE
	WHERE ST_ID_QUARTER = @QR_ID

	IF @@ROWCOUNT = 0
		INSERT INTO Ric.Stage(ST_ID_QUARTER, ST_VALUE)
			SELECT @QR_ID, @VALUE
END

GO
GRANT EXECUTE ON [Ric].[STAGE_SAVE] TO rl_ric_kbu;
GO