﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Clients].[VendorDeleted]', 'V ') IS NULL EXEC('CREATE VIEW [Clients].[VendorDeleted]  AS SELECT 1')
GO
ALTER VIEW [Clients].[VendorDeleted]
--WITH SCHEMABINDING
AS
	SELECT
		VD_ID_MASTER, VD_ID, VD_NAME, VD_DATE, VD_END
	FROM
		Clients.VendorAll a
	WHERE VD_REF = 3GO
