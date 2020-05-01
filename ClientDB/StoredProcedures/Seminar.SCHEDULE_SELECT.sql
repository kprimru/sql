USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Seminar].[SCHEDULE_SELECT]
	@BEGIN		SMALLDATETIME 		= NULL,
	@END		SMALLDATETIME 		= NULL,
	@CLIENT		NVARCHAR(128) 		= NULL,
	@PERSONAL	NVARCHAR(128) 		= NULL,
	@SUBJECT	UNIQUEIDENTIFIER	= NULL,
	@SERVICE	INT					= NULL
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
			a.ID, DATE, LIMIT,
			ID_SUBJECT, b.NAME, b.NOTE, b.READER,
			(
				SELECT COUNT(*)
				FROM Seminar.PersonalView z WITH(NOEXPAND)
				WHERE z.ID_SCHEDULE = a.ID
					AND z.INDX = 1
			) AS PER_COUNT,
			CONVERT(VARCHAR(20), DATE, 104) + ' ' + b.NAME AS TSC_LOOKUP
		FROM
			Seminar.Schedule a
			INNER JOIN Seminar.Subject b ON a.ID_SUBJECT = b.ID
		WHERE (a.DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (a.DATE <= @END OR @END IS NULL)
			AND (a.ID_SUBJECT = @SUBJECT OR @SUBJECT IS NULL)
			AND
				(
					@CLIENT IS NULL
					OR
					EXISTS
						(
							SELECT *
							FROM Seminar.PersonalView z WITH(NOEXPAND)
							WHERE z.ID_SCHEDULE = a.ID
								AND z.ClientFullName LIKE @CLIENT
						)
				)
			AND
				(
					@PERSONAL IS NULL
					OR
					EXISTS
						(
							SELECT *
							FROM Seminar.PersonalView z WITH(NOEXPAND)
							WHERE z.ID_SCHEDULE = a.ID
								AND z.FIO LIKE @PERSONAL
						)
				)
			AND
				(
					@SERVICE IS NULL
					OR
					EXISTS
						(
							SELECT *
							FROM Seminar.PersonalView z WITH(NOEXPAND)
							WHERE z.ID_SCHEDULE = a.ID
								AND z.ServiceID = @SERVICE
						)
				)
		ORDER BY DATE DESC, TIME DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Seminar].[SCHEDULE_SELECT] TO rl_seminar;
GO