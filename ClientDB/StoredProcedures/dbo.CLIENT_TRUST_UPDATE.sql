USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_TRUST_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_TRUST_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_TRUST_UPDATE]
	@ID			UNIQUEIDENTIFIER,
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
	@NOTE		VARCHAR(MAX)
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

		DECLARE @CT_ID	UNIQUEIDENTIFIER

		SELECT @CT_ID = CT_ID
		FROM dbo.ClientTrust
		WHERE CT_ID_CALL = @ID

		UPDATE	dbo.ClientTrust
		SET		CT_TNAME		=	@TNAME,
				CT_NAME			=	@NAME,
				CT_TADDRESS		=	@TADDRESS,
				CT_ADDRESS		=	@ADDRESS,
				CT_TDIR			=	@TDIR,
				CT_DIR			=	@DIR,
				CT_TDIR_POS		=	@TDIR_POS,
				CT_DIR_POS		=	@DIR_POS,
				CT_TDIR_PHONE	=	@TDIR_PHONE,
				CT_DIR_PHONE	=	@DIR_PHONE,
				CT_TBUH			=	@TBUH,
				CT_BUH			=	@BUH,
				CT_TBUH_POS		=	@TBUH_POS,
				CT_BUH_POS		=	@BUH_POS,
				CT_TBUH_PHONE	=	@TBUH_PHONE,
				CT_BUH_PHONE	=	@BUH_PHONE,
				CT_TRES			=	@TRES,
				CT_RES			=	@RES,
				CT_TRES_POS		=	@TRES_POS,
				CT_RES_POS		=	@RES_POS,
				CT_TRES_PHONE	=	@TRES_PHONE,
				CT_RES_PHONE	=	@RES_PHONE,
				CT_TRUST		=	@TRUST,
				CT_NOTE			=	@NOTE
		WHERE	CT_ID = @CT_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_TRUST_UPDATE] TO rl_client_trust_u;
GO
