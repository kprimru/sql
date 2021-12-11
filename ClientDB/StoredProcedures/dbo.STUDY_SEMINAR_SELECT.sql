USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STUDY_SEMINAR_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STUDY_SEMINAR_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[STUDY_SEMINAR_SELECT]
	@CLIENT	INT
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

		SELECT SC.DATE, S.NAME, CNT = COUNT(*)
		FROM Seminar.Schedule		AS SC
		INNER JOIN Seminar.Subject	AS S	ON S.ID = SC.ID_SUBJECT
		INNER JOIN Seminar.Personal	AS P	ON P.ID_SCHEDULE = SC.ID
		INNER JOIN Seminar.Status	AS SS	ON SS.ID = P.ID_STATUS
		WHERE	P.STATUS = 1
			AND	SS.INDX = 1
			AND SC.DATE <= dbo.DateOf(GetDate())
			AND P.ID_CLIENT = @CLIENT
		GROUP BY SC.DATE, S.NAME
		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_SEMINAR_SELECT] TO rl_client_study_r;
GO
