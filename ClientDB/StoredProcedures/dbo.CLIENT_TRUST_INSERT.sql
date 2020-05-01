USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_TRUST_INSERT]
	@CALL		UNIQUEIDENTIFIER,
	@TNAME		BIT,
	@NAME		VARCHAR(500),
	@TADDRESS	BIT,
	@ADDRESS	VARCHAR(500),
	@TDIR		BIT,
	@DIR		VARCHAR(250),
	@TDIR_POS	BIT,
	@DIR_POS	VARCHAR(250),
	@TDIR_PHONE	BIT,
	@DIR_PHONE	VARCHAR(150),
	@TBUH		BIT,
	@BUH		VARCHAR(250),
	@TBUH_POS	BIT,
	@BUH_POS	VARCHAR(250),
	@TBUH_PHONE	BIT,
	@BUH_PHONE	VARCHAR(150),
	@TRES		BIT,
	@RES		VARCHAR(250),
	@TRES_POS	BIT,
	@RES_POS	VARCHAR(150),
	@TRES_PHONE	BIT,
	@RES_PHONE	VARCHAR(150),
	@TRUST		BIT,
	@NOTE		VARCHAR(MAX),
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT
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

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO	dbo.ClientTrust(
					CT_ID_CALL, CT_TNAME, CT_NAME, CT_TADDRESS, CT_ADDRESS,
					CT_TDIR, CT_DIR, CT_TDIR_POS, CT_DIR_POS, CT_TDIR_PHONE, CT_DIR_PHONE,
					CT_TBUH, CT_BUH, CT_TBUH_POS, CT_BUH_POS, CT_TBUH_PHONE, CT_BUH_PHONE,
					CT_TRES, CT_RES, CT_TRES_POS, CT_RES_POS, CT_TRES_PHONE, CT_RES_PHONE,
					CT_TRUST, CT_NOTE)
			OUTPUT INSERTED.CT_ID INTO @TBL
			VALUES(
					@CALL, @TNAME, @NAME, @TADDRESS, @ADDRESS,
					@TDIR, @DIR, @TDIR_POS, @DIR_POS, @TDIR_PHONE, @DIR_PHONE,
					@TBUH, @BUH, @TBUH_POS, @BUH_POS, @TBUH_PHONE, @BUH_PHONE,
					@TRES, @RES, @TRES_POS, @RES_POS, @TRES_PHONE, @RES_PHONE,
					@TRUST, @NOTE)

		SELECT @ID = ID FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_TRUST_INSERT] TO rl_client_trust_i;
GO