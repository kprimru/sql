USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Install].[InstallDetailView]
WITH SCHEMABINDING
AS
	SELECT
		IND_ID, IND_ID_INSTALL AS INS_ID, IND_LOCK,
		IND_BOX_DATE, IND_ACT_DATE, IND_ACT_RETURN,
		SYS_ID, SYS_ID_MASTER, SYS_SHORT,
		DT_ID, DT_ID_MASTER, DT_NAME, DT_SHORT,
		NT_ID, NT_ID_MASTER, NT_NAME,
		TT_ID, TT_ID_MASTER, TT_NAME, TT_SHORT,
		IND_DISTR, IND_ID_PERSONAL,
		IND_CONTRACT, IND_CLAIM,
		IND_ID_INCOME, IND_INSTALL_DATE, IND_ID_CLAIM,
		CASE
			WHEN TT_REG = 0 THEN NT_NAME
			ELSE TT_SHORT
		END AS NT_NEW_NAME,
		IND_ID_ACT, IND_ACT_SIGN, IND_ACT_MAIL, IND_ACT_NOTE,
		IND_TO_NUM, IND_LIMIT, IND_ARCHIVE
	FROM
		Install.InstallDetail											INNER JOIN
		Distr.SystemDetail		ON	SYS_ID_MASTER	=	IND_ID_SYSTEM	INNER JOIN
		Distr.DistrTypeDetail	ON	DT_ID_MASTER	=	IND_ID_TYPE		INNER JOIN
		Distr.NetTypeDetail		ON	NT_ID_MASTER	=	IND_ID_NET		INNER JOIN
		Distr.TechTypeDetail	ON	TT_ID_MASTER	=	IND_ID_TECH
	WHERE SYS_REF IN (1, 3) AND DT_REF IN (1, 3) AND NT_REF IN (1, 3) AND TT_REF IN (1, 3)
		