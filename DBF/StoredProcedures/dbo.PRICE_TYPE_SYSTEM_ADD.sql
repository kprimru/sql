USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[PRICE_TYPE_SYSTEM_ADD]
	@PT_ID	SMALLINT,
	@SST_ID	SMALLINT,
	@ACTIVE	BIT,
	@RETURN BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.PriceTypeSystemTable(PTS_ID_PT, PTS_ID_ST, PTS_ACTIVE)
		VALUES(@PT_ID, @SST_ID, @ACTIVE)

	IF @RETURN = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN
END
