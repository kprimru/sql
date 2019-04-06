USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRICE_SYSTEM_TYPE_ADD]
	@SYS_ID	SMALLINT,
	@PT_ID	SMALLINT,
	@SST_ID	SMALLINT,
	@COEF	DECIMAL(8, 4),
	@FIXED	MONEY,
	@DISC	DECIMAL(8, 4),
	@START	SMALLDATETIME,
	@END	SMALLDATETIME,
	@ACTIVE	BIT,
	@RETURN	BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.PriceSystemType(PST_ID_SYSTEM, PST_ID_PRICE, PST_ID_TYPE, PST_COEF, PST_FIXED, PST_DISCOUNT, PST_START, PST_END, PST_ACTIVE)
		VALUES(@SYS_ID, @PT_ID, @SST_ID, @COEF, @FIXED, @DISC, @START, @END, @ACTIVE)

	IF @RETURN = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN
END
