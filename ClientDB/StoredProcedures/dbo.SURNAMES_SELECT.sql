USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SURNAMES_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT LTRIM(RTRIM(CP_SURNAME)) AS CP_SURNAME
	FROM
		(
			SELECT DISTINCT CP_SURNAME
			FROM 
				dbo.ClientTable a
				INNER JOIN dbo.ClientPersonal b ON a.ClientID = b.CP_ID_CLIENT
			WHERE a.STATUS = 1 AND CP_SURNAME <> '' AND CP_SURNAME <> '-' AND StatusID = 2
			/*
			UNION 

			SELECT DISTINCT SSP_SURNAME
			FROM Training.SeminarSignPersonal
			WHERE SSP_SURNAME <> '' AND SSP_SURNAME <> '-'
			*/
			/*
			UNION
			
			SELECT DISTINCT SURNAME
			FROM 
				dbo.ClientStudyPeople a
				INNER JOIN dbo.ClientStudy b ON a.ID_STUDY = b.ID
			WHERE b.STATUS = 1
			
			UNION
			
			SELECT DISTINCT SURNAME
			FROM 
				dbo.ClientStudyClaimPeople a
				INNER JOIN dbo.ClientStudyClaim b ON a.ID_CLAIM = b.ID
			WHERE b.STATUS = 1
			*/
		) AS o_O
	ORDER BY CP_SURNAME
END
