USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_RIVAL_EDIT]
	@CR_ID	INT,
	@TYPE	INT,
	@STATUS	INT,
	@CONDITION	VARCHAR(MAX),
	@PERSONAL	VARCHAR(MAX),
	@SURNAME	NVARCHAR(256) = NULL,
	@NAME		NVARCHAR(256) = NULL,
	@PATRON		NVARCHAR(256) = NULL,
	@PHONE		NVARCHAR(256) = NULL
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

		DECLARE @ID INT

		INSERT INTO dbo.ClientRival(CR_ID_MASTER, CL_ID, CR_DATE, CR_ID_TYPE, CR_ID_STATUS, CR_COMPLETE, CR_CONTROL, CR_CONDITION, CR_SURNAME, CR_NAME, CR_PATRON, CR_PHONE, CR_CREATE_USER, CR_CREATE_DATE)
			SELECT CR_ID_MASTER, CL_ID, CR_DATE, @TYPE, @STATUS, CR_COMPLETE, CR_CONTROL, @CONDITION, @SURNAME, @NAME, @PATRON, @PHONE, CR_CREATE_USER, CR_CREATE_DATE
			FROM dbo.ClientRival
			WHERE CR_ID = @CR_ID

		SELECT @ID = SCOPE_IDENTITY()

		UPDATE dbo.ClientRivalReaction
		SET CRR_ID_RIVAL = @ID
		WHERE CRR_ID_RIVAL = @CR_ID

		UPDATE dbo.ClientRival
		SET CR_ACTIVE = 0
		WHERE CR_ID = @CR_ID

		EXEC dbo.CLIENT_RIVAL_PERSONAL_SET_NEW @ID, @PERSONAL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_RIVAL_EDIT] TO rl_client_rival_u;
GO