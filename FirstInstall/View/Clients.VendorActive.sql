USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Clients].[VendorActive]
--WITH SCHEMABINDING
AS
	SELECT
		VD_ID_MASTER, VD_ID, VD_NAME, VD_DATE, VD_END
	FROM
		Clients.VendorAll
	WHERE VD_REF = 1GO
