USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STUDY_VISIT_FILTER]
	@TEACHER	INT,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@CLIENT		NVARCHAR(256)
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

		SELECT c.ClientID, c.ClientFullName, b.TeacherName, a.DATE, a.NOTE
		FROM
			dbo.ClientStudyVisit a
			INNER JOIN dbo.TeacherTable b ON a.ID_TEACHER = b.TeacherID
			INNER JOIN dbo.ClientTable c ON c.ClientID = a.ID_CLIENT
		WHERE a.STATUS = 1
			AND (ID_TEACHER = @TEACHER OR @TEACHER IS NULL)
			AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
			AND (DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (DATE <= @END OR @END IS NULL)
		ORDER BY DATE DESC, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_VISIT_FILTER] TO rl_filter_study_visit;
GO
