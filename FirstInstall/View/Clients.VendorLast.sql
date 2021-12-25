﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [Clients].[VendorLast]
--WITH SCHEMABINDING
AS
	SELECT
		VD_ID_MASTER, VD_ID, VD_NAME, VD_DATE, VD_END
	FROM
		Clients.VendorAll a
	WHERE VD_REF IN (1, 3)GO
