USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [Client].[CompanyCreateView]
AS
	SELECT ID, BDATE, UPD_USER
	FROM
		(
			SELECT ID	
			FROM Client.Company
			WHERE STATUS = 1 OR STATUS = 3
		) AS a
		CROSS APPLY
		(
			SELECT TOP 1 BDATE, UPD_USER
			FROM 
				(
					SELECT BDATE, UPD_USER
					FROM Client.Company z
					WHERE z.ID_MASTER = a.ID
						AND z.STATUS = 2
						
					UNION ALL

					SELECT BDATE, UPD_USER
					FROM Client.Company z
					WHERE z.ID = a.ID
						AND z.STATUS = 1				
				) AS o_O
			ORDER BY BDATE
		) AS c