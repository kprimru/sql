USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DUTY_WARNING]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DUTY_WARNING]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_DUTY_WARNING]
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
			DutyName, CallTypeName,
			ClientDutyNPO, ClientDutyComment, e.NAME
		FROM
			dbo.ClientDutyTable a
			INNER JOIN dbo.ClientTable b ON a.ClientID = b.ClientID
			INNER JOIN dbo.DutyTable c ON c.DutyID = a.DutyID
			LEFT OUTER JOIN dbo.CallTypeTable d ON d.CallTypeID = a.CallTypeID
			LEFT OUTER JOIN dbo.CallDirection e ON e.ID = a.ID_DIRECTION
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
GRANT EXECUTE ON [dbo].[CLIENT_DUTY_WARNING] TO rl_duty_warning;
GO
