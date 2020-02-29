USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_RIVAL_REACTION_ADD]
	@CR_ID	INT,
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

		DECLARE @ID INT

		INSERT INTO dbo.ClientRivalReaction(CRR_ID_RIVAL, CRR_DATE, CRR_COMMENT, CRR_COMPARE, CRR_CLAIM, CRR_REJECT, CRR_PARTNER)
			VALUES(@CR_ID, @DATE, @COMM, @COMPARE, @CLAIM, @REJECT, @PARTNER)

		SELECT @ID = SCOPE_IDENTITY()

		UPDATE dbo.ClientRivalReaction
		SET CRR_ID_MASTER = @ID
		WHERE CRR_ID = @ID

		IF @COMPLETE = 1
			UPDATE dbo.ClientRival
			SET CR_COMPLETE = 1,
				CR_CONTROL = 0
			WHERE CR_ID = @CR_ID
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END