USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GET_CLIENT_STUDY]
	@clientid INT
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
			StudyDate, 
			StudyDate AS StudyDateStr,
			RepeatDate AS RepeatDateStr,
			LessonPlaceName, a.LessonPlaceID, TeacherName, a.TeacherID, OwnershipName, a.OwnershipID,
			SystemNeed, Recomend, StudyNote, ClientStudyID, Teached
		FROM 
			dbo.ClientStudyTable a LEFT OUTER JOIN
			dbo.LessonPlaceTable b ON a.LessonPlaceId = b.LessonPlaceID LEFT OUTER JOIN
			dbo.TeacherTable c ON a.TeacherID = c.TeacherID LEFT OUTER JOIN
			dbo.OwnershipTable d ON a.OwnershipID = d.OwnershipID
		WHERE ClientID = @clientid
		ORDER BY StudyDate DESC, ClientStudyID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
