USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DUTY_RESULT]
	@DUTY		INT,
	@ANS		TINYINT,
	@ANS_NOTE	NVARCHAR(MAX),
	@SAT		TINYINT,
	@SAT_NOTE	NVARCHAR(MAX)
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

		DECLARE @ID UNIQUEIDENTIFIER

		SELECT @ID = ID
		FROM dbo.ClientDutyResult
		WHERE ID_DUTY = @DUTY

		IF @ID IS NULL
			INSERT INTO dbo.ClientDutyResult(ID_DUTY, ANSWER, ANSWER_NOTE, SATISF, SATISF_NOTE)
				VALUES(@DUTY, @ANS, @ANS_NOTE, @SAT, @SAT_NOTE)
		ELSE
			UPDATE dbo.ClientDutyResult
			SET ANSWER = @ANS,
				ANSWER_NOTE = @ANS_NOTE,
				SATISF = @SAT,
				SATISF_NOTE = @SAT_NOTE
			WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DUTY_RESULT] TO rl_client_duty_result;
GO
