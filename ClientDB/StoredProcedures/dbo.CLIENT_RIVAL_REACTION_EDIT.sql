USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_RIVAL_REACTION_EDIT]
	@CRR_ID	INT,
	@DATE	SMALLDATETIME,
	@COMM	VARCHAR(MAX),
	@COMPLETE	BIT,
	@COMPARE	BIT = 0,
	@CLAIM		BIT = 0,
	@REJECT		BIT = 0,
	@PARTNER	BIT = 0
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

		INSERT INTO dbo.ClientRivalReaction(CRR_ID_MASTER, CRR_ID_RIVAL, CRR_DATE, CRR_COMMENT, CRR_COMPARE, CRR_CLAIM, CRR_REJECT, CRR_PARTNER, CRR_CREATE_DATE, CRR_CREATE_USER)
			SELECT CRR_ID_MASTER, CRR_ID_RIVAL, @DATE, @COMM, @COMPARE, @CLAIM, @REJECT, @PARTNER, CRR_CREATE_DATE, CRR_CREATE_USER
			FROM dbo.ClientRivalReaction
			WHERE CRR_ID = @CRR_ID

		UPDATE dbo.ClientRivalReaction
		SET CRR_ACTIVE = 0
		WHERE CRR_ID = @CRR_ID

		IF @COMPLETE = 1
			UPDATE dbo.ClientRival
			SET CR_COMPLETE = 1,
				CR_CONTROL = 0
			WHERE CR_ID = (SELECT CRR_ID_RIVAL FROM dbo.ClientRivalReaction WHERE CRR_ID = @CRR_ID)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_RIVAL_REACTION_EDIT] TO rl_client_rival_reaction_u;
GO