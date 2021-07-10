USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_KBU_ADD]
	@SH_ID	SMALLINT,
	@SYS_ID	SMALLINT,
	@KBU	DECIMAL(8, 4),
	@ACTIVE	BIT,
	@return	BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Subhost.SubhostKBUTable(SK_ID_HOST, SK_ID_SYSTEM, SK_KBU, SK_ACTIVE)
		VALUES(@SH_ID, @SYS_ID, @KBU, @ACTIVE)

	IF @RETURN = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_KBU_ADD] TO rl_subhost_kbu_w;
GO