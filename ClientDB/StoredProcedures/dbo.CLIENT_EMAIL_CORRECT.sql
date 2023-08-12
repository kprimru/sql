USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_EMAIL_CORRECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_EMAIL_CORRECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_EMAIL_CORRECT]
	@Id			Int,
	@OldEmail	VarChar(256),
	@NewEmail	VarChar(256)
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

		UPDATE dbo.ClientTable SET
			ClientEmail = @NewEmail
		WHERE ClientID = @Id
			AND STATUS = 1
			AND ClientEmail = @OldEmail;

		UPDATE P SET
			CP_EMAIL = @NewEmail
		FROM dbo.ClientPersonal AS P
		INNER JOIN dbo.ClientTable ON ClientID = CP_ID_CLIENT
		WHERE CP_ID_CLIENT = @Id
			AND STATUS = 1
			AND CP_EMAIL = @OldEmail;


		UPDATE dbo.ClientDelivery SET
			EMAIL = @NewEmail
		WHERE ID_CLIENT = @Id
			AND EMAIL = @OldEmail;

		UPDATE dbo.ClientDutyTable SET
			EMAIL = @NewEmail
		WHERE ClientID = @Id
			AND STATUS = 1
			AND EMAIL = @OldEmail;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_EMAIL_CORRECT] TO rl_client_email_correct;
GO
