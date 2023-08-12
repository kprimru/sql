USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_STUDY_PEOPLE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[GET_STUDY_PEOPLE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[GET_STUDY_PEOPLE]
	@clientstudyid INT
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
			StudyPeopleCount, (StudentFam + ' ' + StudentName + ' ' + StudentOtch) AS StudentFullName,
			StudentPositionName, a.StudentPositionID, StudyNumber, Sertificat, StudentName, StudentFam, StudentOtch, StudyPeopleID, Department,
			SertificatCount, SertificatType
		FROM
			dbo.StudyPeopleTable a LEFT OUTER JOIN
			dbo.StudentPositionTable b ON a.StudentPositionID = b.StudentPositionID
		WHERE ClientStudyID = @clientstudyid
		ORDER BY StudentFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[GET_STUDY_PEOPLE] TO rl_client_study_r;
GO
