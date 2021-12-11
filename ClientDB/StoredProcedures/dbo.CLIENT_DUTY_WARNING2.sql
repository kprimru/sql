USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DUTY_WARNING2]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DUTY_WARNING2]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_DUTY_WARNING2]
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

		SELECT
			b.ClientID, ClientFullName,
			ClientDutyDateTime,
			DutyId, CallTypeId, ID_DIRECTION,
			ClientDutyNPO, ClientDutyComment
		FROM dbo.ClientDutyTable a
		-- ToDo. Почему оптимизатор настойчиво не хочет LOOP сам делать? Есть подозрение, что проблема в STATUS = 1
		INNER LOOP JOIN dbo.ClientTable b ON a.ClientID = b.ClientID
		WHERE ClientDutyComplete = 0 AND a.STATUS = 1
		ORDER BY ClientDutyDateTime DESC, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DUTY_WARNING2] TO rl_duty_warning;
GO
