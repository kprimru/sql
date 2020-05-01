USE [DBF]
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

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO Subhost.SubhostKBUTable(SK_ID_HOST, SK_ID_SYSTEM, SK_KBU, SK_ACTIVE)
			VALUES(@SH_ID, @SYS_ID, @KBU, @ACTIVE)

		IF @RETURN = 1
			SELECT SCOPE_IDENTITY() AS NEW_IDEN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Subhost].[SUBHOST_KBU_ADD] TO rl_subhost_kbu_w;
GO