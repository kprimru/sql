USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[PERSONAL_PRINT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[PERSONAL_PRINT]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[PERSONAL_PRINT]
	@ID	UNIQUEIDENTIFIER
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
			ROW_NUMBER() OVER (ORDER BY a.ClientFullName, SURNAME, NAME, PATRON) AS RN,
			a.ClientFullName, FIO,
			POSITION, PHONE, a.ServiceName, ManagerName,
			NOTE, CASE ISNULL(NOTE, '') WHEN '' THEN 0 ELSE 1 END AS NOTE_EXISTS
		FROM
			dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN Seminar.PersonalView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
		WHERE ID_SCHEDULE = @ID AND INDX = 1
		ORDER BY a.ClientFullName, FIO

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[PERSONAL_PRINT] TO rl_seminar;
GO
