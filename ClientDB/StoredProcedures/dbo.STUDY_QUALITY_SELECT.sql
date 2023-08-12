USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STUDY_QUALITY_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STUDY_QUALITY_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[STUDY_QUALITY_SELECT]
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

		SELECT
			a.ID, DATE, NOTE, TeacherID, TeacherName, ID_TYPE, c.NAME,
			WEIGHT, SYS_LIST,
			REVERSE(STUFF(REVERSE(
				(
					SELECT SystemShortName + ', '
					FROM
						dbo.TableIDFromXML(SYS_LIST)
						INNER JOIN dbo.SystemTable ON SystemID = ID
					ORDER BY ID FOR XML PATH('')
				)
			), 1, 2, '')) AS SYS_STR
		FROM
			dbo.StudyQuality a
			INNER JOIN dbo.TeacherTable b ON ID_TEACHER = TeacherID
			INNER JOIN dbo.StudyQualityType c ON c.ID = a.ID_TYPE
		WHERE ID_CLIENT = @CLIENT
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
GRANT EXECUTE ON [dbo].[STUDY_QUALITY_SELECT] TO rl_client_study_r;
GO
