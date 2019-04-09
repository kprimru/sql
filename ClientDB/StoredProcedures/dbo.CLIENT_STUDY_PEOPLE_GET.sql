USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_STUDY_PEOPLE_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT StudyPeopleID, ClientStudyID, StudentFam, StudentName, StudentOtch, StudentPositionID, StudyNumber, Sertificat, StudyPeopleCount, Department, SertificatCount, SertificatType
	FROM dbo.StudyPeopleTable
	WHERE StudyPeopleID = @ID
END
