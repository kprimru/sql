USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[ClientEmailView]
AS
	SELECT ClientID, ClientEMail
	FROM dbo.ClientTable
	WHERE ISNULL(ClientEMail, '') <> ''
		AND STATUS = 1

	UNION ALL

	SELECT DISTINCT CP_ID_CLIENT, CP_EMAIL
	FROM
		dbo.ClientPersonal
		INNER JOIN dbo.ClientTable ON ClientID = CP_ID_CLIENT
	WHERE ISNULL(CP_EMAIL, '') <> '' AND STATUS = 1

	UNION ALL

	SELECT DISTINCT ID_CLIENT, EMAIL
	FROM dbo.ClientDelivery
	WHERE ISNULL(EMAIL, '') <> ''
