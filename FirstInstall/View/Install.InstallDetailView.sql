﻿USE [FirstInstall]
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
		IND_TO_NUM, IND_LIMIT, IND_ARCHIVE,
		IND_ID_ACT_PERSONAL
	FROM
		Install.InstallDetail											INNER JOIN
		Distr.SystemDetail		ON	SYS_ID_MASTER	=	IND_ID_SYSTEM	INNER JOIN
		Distr.DistrTypeDetail	ON	DT_ID_MASTER	=	IND_ID_TYPE		INNER JOIN
		Distr.NetTypeDetail		ON	NT_ID_MASTER	=	IND_ID_NET		INNER JOIN
		Distr.TechTypeDetail	ON	TT_ID_MASTER	=	IND_ID_TECH
	WHERE SYS_REF IN (1, 3) AND DT_REF IN (1, 3) AND NT_REF IN (1, 3) AND TT_REF IN (1, 3)

GO
CREATE UNIQUE CLUSTERED INDEX [UC_Install.InstallDetailView(IND_ID)] ON [Install].[InstallDetailView] ([IND_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_Install.InstallDetailView(IND_ACT_DATE,IND_DISTR)+INCL] ON [Install].[InstallDetailView] ([IND_ACT_DATE] ASC, [IND_DISTR] ASC) INCLUDE ([IND_ID], [INS_ID], [SYS_SHORT], [IND_ID_PERSONAL], [IND_ID_INCOME], [IND_ID_ACT]);
CREATE NONCLUSTERED INDEX [IX_Install.InstallDetailView(IND_ACT_MAIL,IND_INSTALL_DATE)+(INS_ID,IND_ID_PERSONAL,IND_ID_ACT)] ON [Install].[InstallDetailView] ([IND_ACT_MAIL] ASC, [IND_INSTALL_DATE] ASC) INCLUDE ([INS_ID], [IND_ID_PERSONAL], [IND_ID_ACT]);
CREATE NONCLUSTERED INDEX [IX_Install.InstallDetailView(IND_ACT_RETURN,IND_ACT_DATE,IND_DISTR,IND_CONTRACT,IND_CLAIM)] ON [Install].[InstallDetailView] ([IND_ACT_RETURN] ASC, [IND_ACT_DATE] ASC, [IND_DISTR] ASC, [IND_CONTRACT] ASC, [IND_CLAIM] ASC);
CREATE NONCLUSTERED INDEX [IX_Install.InstallDetailView(IND_CLAIM)] ON [Install].[InstallDetailView] ([IND_CLAIM] ASC);
CREATE NONCLUSTERED INDEX [IX_Install.InstallDetailView(IND_CONTRACT)+INCL] ON [Install].[InstallDetailView] ([IND_CONTRACT] ASC) INCLUDE ([IND_ID], [INS_ID], [SYS_SHORT], [IND_ID_PERSONAL], [IND_ID_INCOME], [IND_ID_CLAIM], [IND_ID_ACT]);
CREATE NONCLUSTERED INDEX [IX_Install.InstallDetailView(IND_DISTR,IND_CONTRACT)] ON [Install].[InstallDetailView] ([IND_DISTR] ASC, [IND_CONTRACT] ASC);
CREATE NONCLUSTERED INDEX [IX_Install.InstallDetailView(IND_INSTALL_DATE)] ON [Install].[InstallDetailView] ([IND_INSTALL_DATE] ASC);
CREATE NONCLUSTERED INDEX [IX_Install.InstallDetailView(INS_ID)+(IND_ID,IND_ID_ACT,IND_ID_INCOME,IND_ID_PERSONAL,SYS_SHORT)] ON [Install].[InstallDetailView] ([INS_ID] ASC) INCLUDE ([IND_ID], [IND_ID_ACT], [IND_ID_INCOME], [IND_ID_PERSONAL], [SYS_SHORT]);
CREATE NONCLUSTERED INDEX [IX_InstallDetailView_IND_ACT_RETURN_IND_ACT_DATE_IND_DISTR_IND_CONTRACT_IND_CLAIM] ON [Install].[InstallDetailView] ([IND_ACT_RETURN] ASC, [IND_ACT_DATE] ASC, [IND_DISTR] ASC, [IND_CONTRACT] ASC, [IND_CLAIM] ASC);
CREATE NONCLUSTERED INDEX [IX_InstallDetailView_IND_ACT_RETURN_IND_ACT_DATE_IND_DISTR_IND_CONTRACT_IND_CLAIM_1] ON [Install].[InstallDetailView] ([IND_ACT_RETURN] ASC, [IND_ACT_DATE] ASC, [IND_DISTR] ASC, [IND_CONTRACT] ASC, [IND_CLAIM] ASC);
CREATE NONCLUSTERED INDEX [IX_InstallDetailView_IND_CLAIM] ON [Install].[InstallDetailView] ([IND_CLAIM] ASC);
GO
