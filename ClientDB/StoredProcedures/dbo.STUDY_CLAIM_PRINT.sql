USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STUDY_CLAIM_PRINT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;


	SELECT 
		DATE, STUDY_DATE, NOTE,
		REVERSE(STUFF(REVERSE(
			(
				SELECT 
					ISNULL(SURNAME, '') + ' ' + ISNULL(e.NAME, '') + ' ' + ISNULL(PATRON, '') + ' ' +
					'(Дожность: ' + ISNULL(POSITION, 'Нет') + 							
					'; телефон: ' + ISNULL(e.PHONE, '') +  
					'; кол-во обученых: ' + ISNULL(CONVERT(VARCHAR(20), GR_COUNT), '1') + ')' + CHAR(10)
				FROM 
					dbo.ClientStudyClaimPeople e					
				WHERE e.ID_CLAIM = a.ID
				ORDER BY SURNAME, e.NAME, PATRON FOR XML PATH('')
			)
		), 1, 2, '')) AS PEOPLE
	FROM dbo.ClientStudyClaim a
	WHERE a.ID = @ID
END
