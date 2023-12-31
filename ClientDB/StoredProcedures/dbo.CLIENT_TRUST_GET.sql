USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_TRUST_GET]
	@ID		UNIQUEIDENTIFIER,
	@CLIENT	INT
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

		SELECT @CT_ID = CT_ID FROM dbo.ClientTrust WHERE CT_ID_CALL = @ID

		IF @CT_ID IS NULL
			SELECT
				CONVERT(BIT, 0) AS CT_TNAME, ClientFullName AS CT_NAME,
				CONVERT(BIT, 0) AS CT_TADDRESS, CA_STR AS CT_ADDRESS,
				CONVERT(BIT, 0) AS CT_TDIR, a.CP_FIO AS CT_DIR,
				CONVERT(BIT, 0) AS CT_TDIR_POS, a.CP_POS AS CT_DIR_POS,
				CONVERT(BIT, 0) AS CT_TDIR_PHONE, a.CP_PHONE AS CT_DIR_PHONE,
				CONVERT(BIT, 0) AS CT_TBUH, b.CP_FIO AS CT_BUH,
				CONVERT(BIT, 0) AS CT_TBUH_POS, b.CP_POS AS CT_BUH_POS,
				CONVERT(BIT, 0) AS CT_TBUH_PHONE, b.CP_PHONE AS CT_BUH_PHONE,
				CONVERT(BIT, 0) AS CT_TRES, c.CP_FIO AS CT_RES,
				CONVERT(BIT, 0) AS CT_TRES_POS, c.CP_POS AS CT_RES_POS,
				CONVERT(BIT, 0) AS CT_TRES_PHONE, c.CP_PHONE AS CT_RES_PHONE,
				CONVERT(BIT, 1) AS CT_TRUST, CONVERT(VARCHAR(MAX), '') AS CT_NOTE
			FROM
				dbo.ClientTable
				LEFT OUTER JOIN dbo.ClientAddressView ON CA_ID_CLIENT = ClientID AND AT_REQUIRED = 1
				LEFT OUTER JOIN dbo.ClientPersonalDirView a WITH(NOEXPAND) ON a.CP_ID_CLIENT = ClientID
				LEFT OUTER JOIN dbo.ClientPersonalBuhView b WITH(NOEXPAND) ON b.CP_ID_CLIENT = ClientID
				LEFT OUTER JOIN dbo.ClientPersonalResView c WITH(NOEXPAND) ON c.CP_ID_CLIENT = ClientID
			WHERE ClientID = @CLIENT
		ELSE
			SELECT
				CT_TNAME, CT_NAME,
				CT_TADDRESS, CT_ADDRESS,
				CT_TDIR, CT_DIR, CT_TDIR_POS, CT_DIR_POS, CT_TDIR_PHONE, CT_DIR_PHONE,
				CT_TBUH, CT_BUH, CT_TBUH_POS, CT_BUH_POS, CT_TBUH_PHONE, CT_BUH_PHONE,
				CT_TRES, CT_RES, CT_TRES_POS, CT_RES_POS, CT_TRES_PHONE, CT_RES_PHONE,
				CT_TRUST, CT_NOTE
			FROM dbo.ClientTrust
			WHERE CT_ID_CALL = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_TRUST_GET] TO rl_client_call_r;
GO
