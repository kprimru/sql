﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[SubhostCompensationView]', 'V ') IS NULL EXEC('CREATE VIEW [Subhost].[SubhostCompensationView]  AS SELECT 1')
GO
ALTER VIEW [Subhost].[SubhostCompensationView]
AS
	SELECT
		SCP_ID,
		SYS_ID, SYS_ORDER, SCP_DISTR, SCP_COMP,
		SYS_SHORT_NAME + ' ' + CONVERT(VARCHAR(20), SCP_DISTR) +
			CASE SCP_COMP
				WHEN 1 THEN ''
				ELSE '/' + CONVERT(VARCHAR(20), SCP_COMP)
			END AS SCP_DISTR_STR,
		SST_CAPTION,
		SN_NAME,
		SCP_COMMENT,
		SCP_ID_SUBHOST, SCP_ID_PERIOD
	FROM
		Subhost.SubhostCompensationTable INNER JOIN
		dbo.SystemTable ON SYS_ID = SCP_ID_SYSTEM INNER JOIN
		dbo.SystemTypeTable ON SST_ID = SCP_ID_TYPE INNER JOIN
		dbo.SystemNetTable ON SN_ID = SCP_ID_NET GO
