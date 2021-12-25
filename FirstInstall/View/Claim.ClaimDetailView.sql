﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Claim].[ClaimDetailView]
--WITH SCHEMABINDING
AS
	SELECT
		CLD_ID, CLD_ID_CLAIM,
		CL_ID, CL_ID_MASTER, CL_NAME,
		VD_ID, VD_ID_MASTER, VD_NAME,
		SYS_ID, SYS_ID_MASTER, SYS_SHORT, SYS_ORDER,
		DT_ID, DT_ID_MASTER, DT_SHORT,
		NT_ID, NT_ID_MASTER, NT_SHORT,
		TT_ID, TT_ID_MASTER, TT_SHORT,
		CLD_COUNT, CLD_COMMENT
	FROM
		Claim.ClaimDetail INNER JOIN
		Clients.ClientLast ON CL_ID_MASTER = CLD_ID_CLIENT INNER JOIN
		Clients.VendorLast ON VD_ID_MASTER = CLD_ID_VENDOR INNER JOIN
		Distr.SystemLast ON SYS_ID_MASTER = CLD_ID_SYSTEM INNER JOIN
		Distr.DistrTypeLast ON DT_ID_MASTER = CLD_ID_TYPE INNER JOIN
		Distr.NetTypeLast ON NT_ID_MASTER = CLD_ID_NET INNER JOIN
		Distr.TechTypeLast ON TT_ID_MASTER = CLD_ID_TECHGO
