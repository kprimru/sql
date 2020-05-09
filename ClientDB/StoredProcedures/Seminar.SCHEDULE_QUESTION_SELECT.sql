USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Seminar].[SCHEDULE_QUESTION_SELECT]
	@SCHEDULE	UniqueIdentifier,
	@CLIENT		NVarChar(128),
	@PERSONAL	NVarChar(128),
	@SERVICE	SmallInt = NULL
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

		SELECT C.ClientId, C.ClientFullName, Q.PSEDO, Q.EMAIL, Q.QUESTION, C.ServiceName
		FROM Seminar.Questions AS Q
		INNER JOIN dbo.ClientView AS C WITH(NOEXPAND) ON Q.ID_CLIENT = C.ClientId
		WHERE Q.ID_SCHEDULE = @SCHEDULE
			AND (PSEDO LIKE @PERSONAL OR @PERSONAL IS NULL)
			AND (C.ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
			AND (C.ServiceId = @SERVICE OR @SERVICE IS NULL)
		ORDER BY C.ClientFullName, Q.PSEDO, Q.ID


		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[SCHEDULE_QUESTION_SELECT] TO rl_seminar;
GO