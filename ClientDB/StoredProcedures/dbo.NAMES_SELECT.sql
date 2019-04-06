USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NAMES_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT LTRIM(RTRIM(CP_NAME)) AS CP_NAME
	FROM
		(
			SELECT DISTINCT CP_NAME
			FROM 
				dbo.ClientTable a
				INNER JOIN dbo.ClientPersonal b ON a.ClientID = b.CP_ID_CLIENT
			WHERE a.STATUS = 1 AND CP_NAME <> '' AND CP_NAME <> '-' AND StatusID = 2
			/*
			UNION 

			SELECT DISTINCT SSP_NAME
			FROM Training.SeminarSignPersonal
			WHERE SSP_NAME <> '' AND SSP_NAME <> '-'
			*/
			/*
			UNION
			
			SELECT DISTINCT NAME
			FROM 
				dbo.ClientStudyPeople a
				INNER JOIN dbo.ClientStudy b ON a.ID_STUDY = b.ID
			WHERE b.STATUS = 1
			
			UNION
			
			SELECT DISTINCT NAME
			FROM 
				dbo.ClientStudyClaimPeople a
				INNER JOIN dbo.ClientStudyClaim b ON a.ID_CLAIM = b.ID
			WHERE b.STATUS = 1
			*/
		) AS o_O
	ORDER BY CP_NAME
END
