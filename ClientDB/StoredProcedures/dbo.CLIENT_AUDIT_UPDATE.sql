USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_AUDIT_UPDATE]
	@ID			INT,
	@CLIENT		INT,
	@DATE		SMALLDATETIME,
	@STUDY		BIT,
	@STUDY_DATE	SMALLDATETIME,
	@SEARCH		BIT,
	@SEARCH_NOTE	VARCHAR(MAX),
	@DUTY		BIT,
	@DUTY_DATE	SMALLDATETIME,
	@DUTY_AVG	DECIMAL(8, 4),
	@TRANSFER	BIT,
	@TRANSFER_NOTE	VARCHAR(MAX),
	@RIVAL		BIT,
	@RIVAL_DATE	SMALLDATETIME,
	@RIVAL_NOTE	VARCHAR(MAX),
	@SYSTEM		BIT,
	@SYSTEM_COUNT	INT,
	@SYSTEM_ER_COUNT	INT,
	@INCOME		BIT,
	@INCOME_NOTE	VARCHAR(MAX),
	@NOTE		VARCHAR(MAX),
	@CONTROL	BIT
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

		UPDATE	dbo.ClientAudit
		SET		CA_DATE = @DATE,
				CA_STUDY = @STUDY,
				CA_STUDY_DATE = @STUDY_DATE,
				CA_SEARCH = @SEARCH,
				CA_SEARCH_NOTE = @SEARCH_NOTE,
				CA_DUTY = @DUTY,
				CA_DUTY_DATE = @DUTY_DATE,
				CA_DUTY_AVG = @DUTY_AVG,
				CA_TRANSFER = @TRANSFER,
				CA_TRANSFER_NOTE = @TRANSFER_NOTE,
				CA_RIVAL = @RIVAL,
				CA_RIVAL_DATE = @RIVAL_DATE,
				CA_RIVAL_NOTE = @RIVAL_NOTE,
				CA_SYSTEM = @SYSTEM,
				CA_SYSTEM_COUNT = @SYSTEM_COUNT,
				CA_SYSTEM_ER_COUNT = @SYSTEM_ER_COUNT,
				CA_INCOME = @INCOME,
				CA_INCOME_NOTE = @INCOME_NOTE,
				CA_NOTE = @NOTE,
				CA_CONTROL = @CONTROL
		WHERE	CA_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_AUDIT_UPDATE] TO rl_client_audit_u;
GO
