﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[USRComplianceView]', 'V ') IS NULL EXEC('CREATE VIEW [USR].[USRComplianceView]  AS SELECT 1')
GO
CREATE OR ALTER VIEW [USR].[USRComplianceView]
WITH SCHEMABINDING
AS
	SELECT UD_ID_CLIENT, UD_ID, UF_ID, UF_DATE, UF_COMPLIANCE
	FROM
		USR.USRData
		INNER JOIN USR.USRFile ON UD_ID = UF_ID_COMPLECT

GO
CREATE UNIQUE CLUSTERED INDEX [UC_USR.USRComplianceView(UF_ID)] ON [USR].[USRComplianceView] ([UF_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_USR.USRComplianceView(UF_COMPLIANCE,UF_DATE)+(UD_ID,UD_ID_CLIENT)] ON [USR].[USRComplianceView] ([UF_COMPLIANCE] ASC, [UF_DATE] ASC) INCLUDE ([UD_ID], [UD_ID_CLIENT]);
GO
