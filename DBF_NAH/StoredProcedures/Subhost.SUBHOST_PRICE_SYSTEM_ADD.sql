USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_PRICE_SYSTEM_ADD]
	@SYS_ID	SMALLINT,
	@PT_ID	SMALLINT,
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@PRICE	MONEY,
	@ACTIVE	BIT,
	@RETURN BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Subhost.SubhostPriceSystemTable
			(
				SPS_ID_SYSTEM, SPS_ID_TYPE, SPS_ID_HOST,
				SPS_ID_PERIOD, SPS_PRICE, SPS_ACTIVE
			)
	VALUES(@SYS_ID, @PT_ID, @SH_ID, @PR_ID, @PRICE, @ACTIVE)

	IF @RETURN = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN
END

GO
