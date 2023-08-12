USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STUDY_QUALITY_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STUDY_QUALITY_FILTER]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[STUDY_QUALITY_FILTER]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TEACHER	INT,
	@TYPE		UNIQUEIDENTIFIER
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

		SELECT a.ID, DATE, NOTE, ClientID, ClientFullName, ManagerName, ServiceName, d.NAME, WEIGHT, TeacherName
		FROM
			dbo.StudyQuality a
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ID_CLIENT = b.ClientID
			INNER JOIN dbo.TeacherTable c ON a.ID_TEACHER = c.TeacherID
			INNER JOIN dbo.StudyQualityType d ON d.ID = a.ID_TYPE
		WHERE (a.DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (a.DATE <= @END OR @END IS NULL)
			AND (a.ID_TEACHER = @TEACHER OR @TEACHER IS NULL)
			AND (a.ID_TYPE = @TYPE OR @TYPE IS NULL)
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
GRANT EXECUTE ON [dbo].[STUDY_QUALITY_FILTER] TO rl_filter_study;
GO
