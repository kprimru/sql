USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientPersonalResView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientPersonalResView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[ClientPersonalResView]
WITH SCHEMABINDING
AS
	SELECT
		CP_ID, CP_ID_CLIENT,
		ISNULL(CP_SURNAME + ' ', '') + ISNULL(CP_NAME + ' ', '') + ISNULL(CP_PATRON, '') AS CP_FIO,
		CP_SURNAME, CP_NAME, CP_PATRON, CP_POS, CP_PHONE, CP_PHONE_S
	FROM
		dbo.ClientPersonal a
		INNER JOIN dbo.ClientPersonalType b ON a.CP_ID_TYPE = b.CPT_ID
	WHERE CPT_PSEDO = 'RES'

GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientPersonalResView(CP_ID_CLIENT)] ON [dbo].[ClientPersonalResView] ([CP_ID_CLIENT] ASC);
GO
