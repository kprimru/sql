USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_PRODUCT_ADD]
	@SPG_ID	SMALLINT,
	@SP_NAME	VARCHAR(100),
	@UN_ID	SMALLINT,
	@COEF	DECIMAL(8, 4),
	@ACTIVE	BIT,
	@return	BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Subhost.SubhostProduct(SP_ID_GROUP, SP_NAME, SP_ID_UNIT, SP_COEF, SP_ACTIVE)
		VALUES(@SPG_ID, @SP_NAME, @UN_ID, @COEF, @ACTIVE)

	IF @RETURN = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_PRODUCT_ADD] TO rl_subhost_product_w;
GO