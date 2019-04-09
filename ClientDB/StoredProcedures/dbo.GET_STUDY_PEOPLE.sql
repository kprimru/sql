USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_STUDY_PEOPLE]
	@clientstudyid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		StudyPeopleCount, (StudentFam + ' ' + StudentName + ' ' + StudentOtch) AS StudentFullName,
		StudentPositionName, a.StudentPositionID, StudyNumber, Sertificat, StudentName, StudentFam, StudentOtch, StudyPeopleID, Department,
		SertificatCount, SertificatType
	FROM 
		dbo.StudyPeopleTable a LEFT OUTER JOIN
		dbo.StudentPositionTable b ON a.StudentPositionID = b.StudentPositionID
	WHERE ClientStudyID = @clientstudyid
	ORDER BY StudentFullName
END