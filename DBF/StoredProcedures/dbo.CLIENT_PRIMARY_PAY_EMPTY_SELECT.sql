USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:		
*/

CREATE PROCEDURE [dbo].[CLIENT_PRIMARY_PAY_EMPTY_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CL_ID, CL_PSEDO, CL_FULL_NAME
	FROM dbo.ClientTable
	WHERE EXISTS
		(
			SELECT * 
			FROM
				dbo.ClientDistrTable LEFT OUTER JOIN 
				dbo.PrimaryPayTable ON PRP_ID_DISTR = CD_ID_DISTR
			WHERE CD_ID_CLIENT = CL_ID AND PRP_ID IS NULL
		)
	ORDER BY CL_PSEDO, CL_ID
END



