USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ClientPersonalBuhLastView]
AS
	SELECT ID_MASTER, CP_SURNAME, CP_NAME, CP_PATRON, CP_POS, CP_PHONE, /*MAX(ClientLast) AS */ClientLast
	FROM 
		dbo.ClientTable a
		INNER JOIN dbo.ClientPersonalBuhView b WITH(NOEXPAND) ON CP_ID_CLIENT = ClientID
	--GROUP BY a.ID_MASTER, CP_SURNAME, CP_NAME, CP_PATRON, CP_POS, CP_PHONE
