USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Clients].[VendorAll]
--WITH SCHEMABINDING
AS
	SELECT
		VD_ID_MASTER, VD_ID, VD_NAME, VD_DATE, VD_END, VD_REF
	FROM
		Clients.VendorDetailGO
