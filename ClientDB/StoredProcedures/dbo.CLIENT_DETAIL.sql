USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_DETAIL]
	@CLIENTID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.ClientID, 
		CASE 
			WHEN ISNULL(ClientOfficial, '') = '' THEN ClientFullName
			ELSE ClientOfficial
		END AS ClientFullName,
		ISNULL(CP_SURNAME + ' ', '') + ISNULL(CP_NAME + ' ', '') + ISNULL(CP_PATRON, '') AS CP_FIO, b.CP_POS,
		b.CP_SURNAME, b.CP_NAME, b.CP_PATRON
	FROM
		dbo.ClientTable a
		LEFT OUTER JOIN dbo.ClientPersonal b ON a.ClientID = b.CP_ID_CLIENT
		LEFT OUTER JOIN dbo.ClientPersonalType c ON b.CP_ID_TYPE = c.CPT_ID AND CPT_PSEDO = 'DIR'
	WHERE a.ClientID = @CLIENTID
END