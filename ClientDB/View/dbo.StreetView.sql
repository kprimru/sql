USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[StreetView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[StreetView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[StreetView]
AS
	SELECT
		ST_ID, ST_NAME, b.CT_ID, b.CT_NAME, ST_PREFIX, ST_SUFFIX,
		e.CT_NAME AS CT_PARENT, b.CT_PREFIX,
		CASE RG_DISPLAY
			WHEN 1 THEN
				CASE RG_PREFIX
					WHEN '' THEN RG_NAME
					ELSE RG_PREFIX + ' ' + RG_NAME
				END +
				CASE RG_SUFFIX
					WHEN '' THEN ''
					ELSE ' ' + RG_SUFFIX
				END + ','
			ELSE ''
		END +
		CASE
			WHEN AR_ID IS NULL THEN ''
			ELSE
				CASE AR_PREFIX
					WHEN '' THEN AR_NAME
					ELSE AR_PREFIX + ' ' + AR_NAME
				END +
				CASE AR_SUFFIX
					WHEN '' THEN ''
					ELSE ' ' + AR_SUFFIX
				END + ','
		END +
		CASE b.CT_DEFAULT
			WHEN 1 THEN ''
			ELSE
				CASE
					WHEN e.CT_ID IS NULL THEN ''
					ELSE
						CASE e.CT_PREFIX
							WHEN '' THEN e.CT_NAME
							ELSE
								CASE ISNULL(e.CT_DISPLAY_PREFIX, 1)
									WHEN 1 THEN e.CT_PREFIX + ' '
									ELSE ''
								END + e.CT_NAME
						END +
						CASE e.CT_SUFFIX
							WHEN '' THEN ''
							ELSE ' ' + e.CT_SUFFIX
						END + ','
				END +
				CASE b.CT_PREFIX
					WHEN '' THEN b.CT_NAME
					ELSE
						CASE ISNULL(b.CT_DISPLAY_PREFIX, 1)
							WHEN 1 THEN b.CT_PREFIX + ' '
							ELSE ''
						END + b.CT_NAME
				END +
				CASE b.CT_SUFFIX
					WHEN '' THEN ''
					ELSE ' ' + b.CT_SUFFIX
				END + ', '
		END +
		CASE ST_PREFIX
			WHEN '' THEN ST_NAME
			ELSE ST_PREFIX + ' ' + ST_NAME
		END +
		CASE ST_SUFFIX
			WHEN '' THEN ''
			ELSE ' ' + ST_SUFFIX
		END AS ST_STR,
		ST_NAME +
		CASE ST_SUFFIX
			WHEN '' THEN ''
			ELSE ', ' + ST_SUFFIX
		END +
		CASE ST_PREFIX
			WHEN '' THEN ''
			ELSE ', ' + ST_PREFIX
		END +
		CASE RG_DISPLAY
			WHEN 1 THEN
				CASE RG_PREFIX
					WHEN '' THEN ', ' + RG_NAME
					ELSE ', ' + RG_PREFIX + ' ' + RG_NAME
				END +
				CASE RG_SUFFIX
					WHEN '' THEN ''
					ELSE ' ' + RG_SUFFIX
				END + ','
			ELSE ''
		END +
		CASE
			WHEN AR_ID IS NULL THEN ''
			ELSE
				CASE AR_PREFIX
					WHEN '' THEN ', ' + AR_NAME
					ELSE ', ' + AR_PREFIX + ' ' + AR_NAME
				END +
				CASE AR_SUFFIX
					WHEN '' THEN ''
					ELSE ' ' + AR_SUFFIX
				END + ','
		END +
		CASE b.CT_DEFAULT
			WHEN 1 THEN ''
			ELSE ', ' + b.CT_NAME
		END +
		CASE
			WHEN e.CT_ID IS NULL THEN ''
			ELSE ', ' + e.CT_NAME
		END AS ST_LOOKUP,



		'Российская Федерация, ' +


		CASE RG_PREFIX
			WHEN '' THEN RG_NAME
			ELSE RG_PREFIX + ' ' + RG_NAME
		END +
		CASE RG_SUFFIX
			WHEN '' THEN ''
			ELSE ' ' + RG_SUFFIX
		END + ', ' +

		CASE
			WHEN AR_ID IS NULL THEN ''
			ELSE
				CASE AR_PREFIX
					WHEN '' THEN AR_NAME
					ELSE AR_PREFIX + ' ' + AR_NAME
				END +
				CASE AR_SUFFIX
					WHEN '' THEN ''
					ELSE ' ' + AR_SUFFIX
				END + ', '
		END +

		CASE
			WHEN e.CT_ID IS NULL THEN ''
			ELSE
				CASE e.CT_PREFIX
					WHEN '' THEN e.CT_NAME
					ELSE
						CASE ISNULL(e.CT_DISPLAY_PREFIX, 1)
							WHEN 1 THEN e.CT_PREFIX + ' '
							ELSE ''
						END + e.CT_NAME
				END +
				CASE e.CT_SUFFIX
					WHEN '' THEN ''
					ELSE ' ' + e.CT_SUFFIX
				END + ', '
		END +

		CASE b.CT_PREFIX
			WHEN '' THEN b.CT_NAME
			ELSE
				CASE ISNULL(b.CT_DISPLAY_PREFIX, 1)
					WHEN 1 THEN b.CT_PREFIX + ' '
					ELSE ''
				END + b.CT_NAME
		END +

		CASE b.CT_SUFFIX
			WHEN '' THEN ''
			ELSE ' ' + b.CT_SUFFIX
		END + ', ' +

		CASE ST_PREFIX
			WHEN '' THEN ST_NAME
			ELSE ST_PREFIX + ' ' + ST_NAME
		END +

		CASE ST_SUFFIX
			WHEN '' THEN ''
			ELSE ' ' + ST_SUFFIX
		END AS ST_FULL
	FROM
		dbo.Street a
		INNER JOIN dbo.City b ON a.ST_ID_CITY = b.CT_ID
		LEFT OUTER JOIN dbo.Area c ON c.AR_ID = b.CT_ID_AREA
		LEFT OUTER JOIN dbo.Region d ON d.RG_ID = b.CT_ID_REGION
		LEFT OUTER JOIN dbo.City e ON b.CT_ID_CITY = e.CT_IDGO
