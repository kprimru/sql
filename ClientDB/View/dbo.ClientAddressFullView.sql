USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[ClientAddressFullView]
AS
	SELECT
		CA_ID, CA_ID_CLIENT, AT_REQUIRED,
			CASE
				WHEN ST_ID IS NULL THEN CA_NOTE
				ELSE
					REVERSE(STUFF(REVERSE(
						CASE
							WHEN ISNULL(CA_INDEX, '') = '' THEN ''
							ELSE CA_INDEX + ', '
						END +
						CASE
							WHEN ISNULL(ST_STR, '') = '' THEN ''
							ELSE ST_STR + ', '
						END +
						CASE
							WHEN ISNULL(CA_HOME, '') = '' THEN ''
							ELSE CA_HOME + ', '
						END +
						CASE
							WHEN ISNULL(CA_OFFICE, '') = '' THEN ''
							ELSE CA_OFFICE + ', '
						END
					), 1, 2, ''))
					/*ISNULL(CA_INDEX + ', ', '') + ISNULL(ST_STR + ', ', '') + ISNULL(CA_HOME + ', ', '') + ISNULL(CA_OFFICE, '') */
			END AS CA_STR,
			CASE
				WHEN ST_ID IS NULL THEN CA_NOTE
				ELSE
					REVERSE(STUFF(REVERSE(
						CASE
							WHEN ISNULL(CA_INDEX, '') = '' THEN ''
							ELSE CA_INDEX + ', '
						END +
						CASE
							WHEN ISNULL(ST_STR, '') = '' THEN ''
							ELSE ST_STR + ', '
						END +
						CASE
							WHEN ISNULL(CA_HOME, '') = '' THEN ''
							ELSE CA_HOME + ', '
						END +
						CASE
							WHEN ISNULL(CA_OFFICE, '') = '' THEN ''
							ELSE CA_OFFICE + ', '
						END +
						CASE
							WHEN ISNULL(CA_HINT, '') = '' THEN ''
							ELSE '(' + CA_HINT + '), '
						END +
						CASE
							WHEN ISNULL(CA_NOTE, '') = '' THEN ''
							ELSE '(' + CA_NOTE + '), '
						END
					), 1, 2, ''))
					--ISNULL(CA_INDEX + ', ', '') + ISNULL(ST_STR + ', ', '') + ISNULL(CA_HOME + ', ', '') + ISNULL(CA_OFFICE, '')
			END AS CA_STR_PRNT
	FROM
		dbo.ClientAddress
		INNER JOIN dbo.AddressType ON CA_ID_TYPE = AT_ID
		LEFT OUTER JOIN dbo.StreetView ON ST_ID = CA_ID_STREET
	--WHERE AT_REQUIRED = 1
