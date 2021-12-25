﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[DistrHistoryView]
AS
	SELECT
		DDH_ID, DIS_STR, c.CL_ID AS CL_OLD_ID, c.CL_PSEDO AS CL_OLD_PSEDO,
		d.CL_ID AS CL_NEW_ID, d.CL_PSEDO AS CL_NEW_PSEDO, DDH_USER, DDH_DATE, DDH_NOTE
	FROM
		dbo.DistrDeliveryHistoryTable a INNER JOIN
		dbo.DistrView b WITH(NOEXPAND) ON DDH_ID_DISTR = DIS_ID INNER JOIN
		dbo.ClientTable c ON c.CL_ID = DDH_ID_OLD_CLIENT INNER JOIN
		dbo.ClientTable d ON d.CL_ID = DDH_ID_NEW_CLIENT
GO
