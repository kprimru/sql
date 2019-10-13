USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[POSITIONS_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT CP_POS
	FROM
		(
			SELECT DISTINCT CP_POS
			FROM 
				dbo.ClientTable a
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
				INNER JOIN dbo.ClientPersonal b ON a.ClientID = b.CP_ID_CLIENT
			WHERE a.STATUS = 1 AND CP_POS <> '' AND CP_POS <> '-' AND CP_POS <> '--'
			/*
			UNION 

			SELECT DISTINCT SSP_POS
			FROM Training.SeminarSignPersonal
			WHERE SSP_POS <> '' AND SSP_POS <> '-' AND SSP_POS <> '--'
			*/
		) AS o_O
	ORDER BY CP_POS
END
