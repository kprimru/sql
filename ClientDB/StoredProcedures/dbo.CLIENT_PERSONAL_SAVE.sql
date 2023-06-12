USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_PERSONAL_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_PERSONAL_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_PERSONAL_SAVE]
	@CLIENT		INT,
	@TYPE		UNIQUEIDENTIFIER,
	@SURNAME	VARCHAR(250),
	@NAME		VARCHAR(250),
	@PATRON		VARCHAR(250),
	@POS		VARCHAR(150),
	@NOTE		VARCHAR(MAX),
	@EMAIL		VARCHAR(50),
	@PHONE		VARCHAR(150),
	@MAP		VARBINARY(MAX) = NULL,
	@FAX		VARCHAR(150) = NULL
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

		SET @SURNAME = LTRIM(RTRIM(@SURNAME))
		SET @NAME = LTRIM(RTRIM(@NAME))
		SET @PATRON = LTRIM(RTRIM(@PATRON))
		SET @POS = LTRIM(RTRIM(@POS))

		INSERT INTO dbo.ClientPersonal(CP_ID_CLIENT, CP_ID_TYPE, CP_SURNAME, CP_NAME, CP_PATRON, CP_POS, CP_NOTE, CP_EMAIL, CP_PHONE, CP_FAX, CP_PHONE_S)
			SELECT @CLIENT, @TYPE, @SURNAME, @NAME, @PATRON, @POS, @NOTE, @EMAIL, @PHONE, @FAX, dbo.PhoneString(@PHONE)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_SAVE] TO rl_client_save;
GO
