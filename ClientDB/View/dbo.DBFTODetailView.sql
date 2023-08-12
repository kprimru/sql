﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DBFTODetailView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[DBFTODetailView]  AS SELECT 1')
GO

CREATE OR ALTER VIEW [dbo].[DBFTODetailView]
AS
	SELECT
		TO_ID, TO_NAME, CL_PSEDO, CL_FULL_NAME, TO_INN, AC_NAME AS ACTIVITY,
		TA_INDEX, TA_HOME, CT_NAME + ', ' + ST_NAME + ', ' + TA_HOME AS ADDR_STR,
		(
			SELECT TOP 1 ST_ID
			FROM
				dbo.Street z
				INNER JOIN dbo.City y ON ST_ID_CITY = CT_ID
			WHERE z.ST_NAME = a.ST_NAME AND y.CT_NAME = b.CT_NAME
		) AS STREET_ID,
		dir.TP_SURNAME AS DIR_SURNAME, dir.TP_NAME AS DIR_NAME, dir.TP_OTCH AS DIR_OTCH, dir.POS_NAME AS DIR_POS, dir.TP_PHONE AS DIR_PHONE,
		buh.TP_SURNAME AS BUH_SURNAME, buh.TP_NAME AS BUH_NAME, buh.TP_OTCH AS BUH_OTCH, buh.POS_NAME AS BUH_POS, buh.TP_PHONE AS BUH_PHONE,
		res.TP_SURNAME AS RES_SURNAME, res.TP_NAME AS RES_NAME, res.TP_OTCH AS RES_OTCH, res.POS_NAME AS RES_POS, res.TP_PHONE AS RES_PHONE
	FROM
		[DBF].[dbo.TOTable]
		INNER JOIN [DBF].[dbo.ClientTable] ON TO_ID_CLIENT = CL_ID
		LEFT OUTER JOIN [DBF].[dbo.TOAddressTable] ON TA_ID_TO = TO_ID
		LEFT OUTER JOIN [DBF].[dbo.StreetTable] a ON ST_ID = TA_ID_STREET
		LEFT OUTER JOIN [DBF].[dbo.CityTable] b ON CT_ID = ST_ID_CITY
		LEFT OUTER JOIN [DBF].[dbo.ActivityTable] ON AC_ID = CL_ID_ACTIVITY
		CROSS APPLY
		(
			SELECT TOP 1 TP_ID_TO, TP_SURNAME, TP_NAME, TP_OTCH, POS_NAME, TP_PHONE
			FROM [DBF].[dbo.TOPersonalTable]
			INNER JOIN [DBF].[dbo.PositionTable] ON POS_ID = TP_ID_POS
			INNER JOIN [DBF].[dbo.ReportPositionTable] ON RP_ID = TP_ID_RP
			WHERE TP_ID_TO = TO_ID AND RP_PSEDO = 'LEAD'
		) AS dir
		CROSS APPLY
		(
			SELECT TOP 1 TP_ID_TO, TP_SURNAME, TP_NAME, TP_OTCH, POS_NAME, TP_PHONE
			FROM [DBF].[dbo.TOPersonalTable]
			INNER JOIN [DBF].[dbo.PositionTable] ON POS_ID = TP_ID_POS
			INNER JOIN [DBF].[dbo.ReportPositionTable] ON RP_ID = TP_ID_RP
			WHERE TP_ID_TO = TO_ID AND RP_PSEDO = 'BUH'
		) AS buh
		CROSS APPLY
		(
			SELECT TOP 1 TP_ID_TO, TP_SURNAME, TP_NAME, TP_OTCH, POS_NAME, TP_PHONE
			FROM [DBF].[dbo.TOPersonalTable]
			INNER JOIN [DBF].[dbo.PositionTable] ON POS_ID = TP_ID_POS
			INNER JOIN [DBF].[dbo.ReportPositionTable] ON RP_ID = TP_ID_RP
			WHERE TP_ID_TO = TO_ID AND RP_PSEDO = 'RES'
		) AS res
GO
