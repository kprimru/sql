USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [Client].[CompanySearchView]
AS
	SELECT 
		a.ID, 
		ISNULL(a.SHORT, '') + ' ' +
		ISNULL(a.NAME, '') + ' ' +
		ISNULL(CONVERT(VARCHAR(20), a.NUMBER), '') + ' ' +
		ISNULL(
			(
				SELECT 
					ISNULL(b.NAME, '') + ' ' +
					ISNULL(b.SHORT, '') + ' ' +
					ISNULL(d.NAME, '') + ' ' +
					ISNULL(e.NAME, '') + ' ' +
					ISNULL(f.NAME, '') + ' ' +
					ISNULL(c.HOME, '') + ' ' + 
					ISNULL(c.ROOM, '') + ' '
				FROM
					Client.Office b
					LEFT OUTER JOIN Client.OfficeAddress c ON c.ID_OFFICE = b.ID
					LEFT OUTER JOIN Address.Street d ON d.ID = c.ID_STREET
					LEFT OUTER JOIN Address.City e ON e.ID = d.ID_CITY
					LEFT OUTER JOIN Address.Area f ON f.ID = c.ID_AREA
				WHERE b.ID_COMPANY = a.ID AND b.STATUS = 1
				FOR XML PATH('')
			), '') + ' ' + 
		ISNULL(
			(
				SELECT 
					ISNULL(PHONE, '') + ' ' + 
					ISNULL(PHONE_S, '') + ' '
				FROM Client.CompanyPhone b
				WHERE b.ID_COMPANY = a.ID
				FOR XML PATH('')
			)
			, '') + ' ' + 
		ISNULL(
			(
				SELECT 
					ISNULL(FIO, '') + ' ' + 
					ISNULL(
						(
							SELECT 
								ISNULL(PHONE, '') + ' ' + 
								ISNULL(PHONE_S, '') + ' '
							FROM Client.CompanyPersonalPhone c
							WHERE b.ID = c.ID_PERSONAL
							FOR XML PATH('')
						)
						, '') + ' '
				FROM Client.CompanyPersonal b
				WHERE b.ID_COMPANY = a.ID
				FOR XML PATH('')
			)
			, '') AS DATA
	FROM Client.Company a	
	WHERE a.STATUS = 1
