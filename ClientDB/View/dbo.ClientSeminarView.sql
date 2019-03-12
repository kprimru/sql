USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[ClientSeminarView]
WITH SCHEMABINDING
AS
	SELECT 
		b.ID AS StudyPeopleID, a.ID_CLIENT AS ClientID, a.DATE AS StudyDate, 
		b.SURNAME AS StudentFam, b.NAME AS StudentName, b.PATRON AS StudentOtch
	FROM 
		dbo.ClientStudy a
		INNER JOIN dbo.ClientStudyPeople b ON a.ID = b.ID_STUDY
	WHERE ID_PLACE = 3 AND STATUS = 1