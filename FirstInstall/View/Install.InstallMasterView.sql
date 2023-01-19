﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Install].[InstallMasterView]', 'V ') IS NULL EXEC('CREATE VIEW [Install].[InstallMasterView]  AS SELECT 1')
GO
ALTER VIEW [Install].[InstallMasterView]
WITH SCHEMABINDING
AS
	SELECT
		INS_ID, INS_DATE,
		CL_ID, CL_ID_MASTER, CL_NAME,
		VD_ID, VD_ID_MASTER, VD_NAME
	FROM
		Install.Install INNER JOIN
		Clients.ClientDetail ON CL_ID_MASTER = INS_ID_CLIENT INNER JOIN
		Clients.VendorDetail ON VD_ID_MASTER = INS_ID_VENDOR
	WHERE CL_REF IN (1, 3) AND VD_REF IN (1, 3)

GO
CREATE UNIQUE CLUSTERED INDEX [UC_Install.InstallMasterView(INS_ID)] ON [Install].[InstallMasterView] ([INS_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_Install.InstallMasterView(CL_NAME)+(INS_ID)] ON [Install].[InstallMasterView] ([CL_NAME] ASC) INCLUDE ([INS_ID]);
CREATE NONCLUSTERED INDEX [IX_Install.InstallMasterView(INS_DATE)+(INS_ID)] ON [Install].[InstallMasterView] ([INS_DATE] ASC) INCLUDE ([INS_ID]);
GO
