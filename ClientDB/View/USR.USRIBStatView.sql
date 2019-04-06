USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [USR].[USRIBStatView]
WITH SCHEMABINDING
AS
	SELECT 		
		UD_ID_CLIENT, UIU_DATE_S, UIU_DOCS, UI_ID_BASE, InfoBankDaily, COUNT_BIG(*) AS CNT
	FROM		
		USR.USRData 
		INNER JOIN USR.USRFile ON UF_ID_COMPLECT = UD_ID 
		INNER JOIN USR.USRIB ON UI_ID_USR = UF_ID 
		INNER JOIN USR.USRUpdates ON UIU_ID_IB = UI_ID
		INNER JOIN dbo.InfoBankTable ON InfoBankID = UI_ID_BASE
	WHERE UD_ID_CLIENT IS NOT NULL AND InfoBankActual = 1
	GROUP BY UD_ID_CLIENT, UIU_DATE_S, UIU_DOCS, UI_ID_BASE, InfoBankDaily
