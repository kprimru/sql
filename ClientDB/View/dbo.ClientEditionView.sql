USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientEditionView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientEditionView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[ClientEditionView]
AS
	SELECT
		ClientID, ID_MASTER, ClientFullName, ServiceName, ManagerName, ClientLast, UPD_USER,
		CA_STR, ClientINN,
		e.CP_FIO AS DIR_FIO, e.CP_POS AS DIR_POS, e.CP_PHONE AS DIR_PHONE,
		f.CP_FIO AS BUH_FIO, f.CP_POS AS BUH_POS, f.CP_PHONE AS BUH_PHONE,
		g.CP_FIO AS RES_FIO, g.CP_POS AS RES_POS, g.CP_PHONE AS RES_PHONE
	FROM
		dbo.ClientUpdateView a WITH(NOEXPAND)
		LEFT OUTER JOIN dbo.ClientAddressView d ON d.CA_ID_CLIENT = a.ClientID
		LEFT OUTER JOIN dbo.ClientPersonalDirView e WITH(NOEXPAND) ON e.CP_ID_CLIENT = a.ClientID
		LEFT OUTER JOIN dbo.ClientPersonalBuhView f WITH(NOEXPAND) ON f.CP_ID_CLIENT = a.ClientID
		LEFT OUTER JOIN dbo.ClientPersonalResView g WITH(NOEXPAND) ON g.CP_ID_CLIENT = a.ClientID
GO
