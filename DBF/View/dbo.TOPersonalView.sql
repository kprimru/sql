﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[TOPersonalView]
AS

SELECT	TP_ID,
		TP_SURNAME, TP_NAME, TP_OTCH,
		TP_PHONE, RP_ID, RP_NAME, RP_PSEDO,
        POS_ID, POS_NAME, POS_SHORT_NAME, TP_ID_TO,
		TO_ID_CLIENT, TO_NAME, TP_PHONE_OLD, TP_LAST
FROM	dbo.TOPersonalTable		TOPT	INNER JOIN
		dbo.ReportPositionTable	RPT		ON	TOPT.TP_ID_RP = RPT.RP_ID	LEFT OUTER JOIN
		dbo.PositionTable		PT		ON	TOPT.TP_ID_POS = PT.POS_ID	LEFT OUTER JOIN
		dbo.TOTable				TOT		ON	TOT.TO_ID=TOPT.TP_ID_TO
GO
