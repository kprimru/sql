USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientAddressLastView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientAddressLastView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[ClientAddressLastView]
AS
	SELECT a.ID_MASTER, CA_ID_STREET, CA_HOME, CA_OFFICE, MAX(ClientLast) AS ClientLast
	FROM
		dbo.ClientTable a
		INNER JOIN dbo.ClientAddress b ON a.ClientID = b.CA_ID_CLIENT
		INNER JOIN dbo.AddressType ON CA_ID_TYPE = AT_ID
	WHERE AT_REQUIRED = 1
	GROUP BY a.ID_MASTER, CA_ID_STREET, CA_HOME, CA_OFFICE
GO
