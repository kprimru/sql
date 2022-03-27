USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Install].[InstallDetail]
(
        [IND_ID]                UniqueIdentifier      NOT NULL,
        [IND_ID_INSTALL]        UniqueIdentifier      NOT NULL,
        [IND_ID_INCOME]         UniqueIdentifier          NULL,
        [IND_ID_SYSTEM]         UniqueIdentifier      NOT NULL,
        [IND_ID_TYPE]           UniqueIdentifier      NOT NULL,
        [IND_ID_NET]            UniqueIdentifier      NOT NULL,
        [IND_ID_TECH]           UniqueIdentifier      NOT NULL,
        [IND_CONTRACT]          SmallDateTime             NULL,
        [IND_ID_CLAIM]          UniqueIdentifier          NULL,
        [IND_CLAIM]             DateTime                  NULL,
        [IND_ID_DISTR]          UniqueIdentifier          NULL,
        [IND_DISTR]             VarChar(50)               NULL,
        [IND_ACT_DATE]          SmallDateTime             NULL,
        [IND_ID_PERSONAL]       UniqueIdentifier          NULL,
        [IND_INSTALL_DATE]      SmallDateTime             NULL,
        [IND_ACT_RETURN]        SmallDateTime             NULL,
        [IND_BOX_DATE]          SmallDateTime             NULL,
        [IND_LOCK]              Bit                   NOT NULL,
        [IND_ID_ACT]            UniqueIdentifier          NULL,
        [IND_ACT_SIGN]          DateTime                  NULL,
        [IND_ACT_MAIL]          DateTime                  NULL,
        [IND_ACT_NOTE]          NVarChar(Max)             NULL,
        [IND_TO_NUM]            Int                       NULL,
        [IND_LIMIT]             SmallDateTime             NULL,
        [IND_ARCHIVE]           SmallDateTime             NULL,
        [IND_ORAGE]             Bit                   NOT NULL,
        [IND_ID_ACT_PERSONAL]   UniqueIdentifier          NULL,
        CONSTRAINT [PK_Install.InstallDetail] PRIMARY KEY CLUSTERED ([IND_ID]),
        CONSTRAINT [FK_Install.InstallDetail(IND_ID_ACT_PERSONAL)_Install.Personals(PERMS_ID)] FOREIGN KEY  ([IND_ID_ACT_PERSONAL]) REFERENCES [Personal].[Personals] ([PERMS_ID]),
        CONSTRAINT [FK_Install.InstallDetail(IND_ID_INSTALL)_Install.Install(INS_ID)] FOREIGN KEY  ([IND_ID_INSTALL]) REFERENCES [Install].[Install] ([INS_ID]),
        CONSTRAINT [FK_Install.InstallDetail(IND_ID_TYPE)_Install.DistrType(DTMS_ID)] FOREIGN KEY  ([IND_ID_TYPE]) REFERENCES [Distr].[DistrType] ([DTMS_ID]),
        CONSTRAINT [FK_Install.InstallDetail(IND_ID_NET)_Install.NetType(NTMS_ID)] FOREIGN KEY  ([IND_ID_NET]) REFERENCES [Distr].[NetType] ([NTMS_ID]),
        CONSTRAINT [FK_Install.InstallDetail(IND_ID_INCOME)_Install.IncomeDetail(ID_ID)] FOREIGN KEY  ([IND_ID_INCOME]) REFERENCES [Income].[IncomeDetail] ([ID_ID]),
        CONSTRAINT [FK_Install.InstallDetail(IND_ID_SYSTEM)_Install.Systems(SYSMS_ID)] FOREIGN KEY  ([IND_ID_SYSTEM]) REFERENCES [Distr].[Systems] ([SYSMS_ID]),
        CONSTRAINT [FK_Install.InstallDetail(IND_ID_TECH)_Install.TechType(TTMS_ID)] FOREIGN KEY  ([IND_ID_TECH]) REFERENCES [Distr].[TechType] ([TTMS_ID]),
        CONSTRAINT [FK_Install.InstallDetail(IND_ID_PERSONAL)_Install.Personals(PERMS_ID)] FOREIGN KEY  ([IND_ID_PERSONAL]) REFERENCES [Personal].[Personals] ([PERMS_ID]),
        CONSTRAINT [FK_Install.InstallDetail(IND_ID_CLAIM)_Install.Claims(CLM_ID)] FOREIGN KEY  ([IND_ID_CLAIM]) REFERENCES [Claim].[Claims] ([CLM_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Install.InstallDetail(IND_ACT_MAIL,IND_INSTALL_DATE)+INCL] ON [Install].[InstallDetail] ([IND_ACT_MAIL] ASC, [IND_INSTALL_DATE] ASC) INCLUDE ([IND_ID_INSTALL], [IND_ID_SYSTEM], [IND_ID_TYPE], [IND_ID_NET], [IND_ID_TECH], [IND_ID_PERSONAL], [IND_ID_ACT]);
CREATE NONCLUSTERED INDEX [IX_Install.InstallDetail(IND_ACT_RETURN,IND_CONTRACT,IND_CLAIM,IND_DISTR,IND_ACT_DATE)+INCL] ON [Install].[InstallDetail] ([IND_ACT_RETURN] ASC, [IND_CONTRACT] ASC, [IND_CLAIM] ASC, [IND_DISTR] ASC, [IND_ACT_DATE] ASC) INCLUDE ([IND_ID], [IND_ID_INSTALL], [IND_ID_INCOME], [IND_ID_SYSTEM], [IND_ID_TYPE], [IND_ID_NET], [IND_ID_TECH], [IND_ID_CLAIM], [IND_ID_PERSONAL], [IND_ID_ACT]);
CREATE NONCLUSTERED INDEX [IX_Install.InstallDetail(IND_CLAIM)] ON [Install].[InstallDetail] ([IND_CLAIM] ASC);
CREATE NONCLUSTERED INDEX [IX_Install.InstallDetail(IND_DISTR,IND_CONTRACT)] ON [Install].[InstallDetail] ([IND_DISTR] ASC, [IND_CONTRACT] ASC);
CREATE NONCLUSTERED INDEX [IX_Install.InstallDetail(IND_ID_INCOME)] ON [Install].[InstallDetail] ([IND_ID_INCOME] ASC);
CREATE NONCLUSTERED INDEX [IX_Install.InstallDetail(IND_ID_INSTALL)] ON [Install].[InstallDetail] ([IND_ID_INSTALL] ASC);
CREATE NONCLUSTERED INDEX [IX_Install.InstallDetail(IND_ID_TECH,IND_INSTALL_DATE)+INCL] ON [Install].[InstallDetail] ([IND_ID_TECH] ASC, [IND_INSTALL_DATE] ASC) INCLUDE ([IND_ID], [IND_ID_INSTALL], [IND_ID_INCOME], [IND_ID_SYSTEM], [IND_ID_TYPE], [IND_ID_NET], [IND_CONTRACT], [IND_ID_CLAIM], [IND_CLAIM], [IND_DISTR], [IND_ACT_DATE], [IND_ID_PERSONAL], [IND_ACT_RETURN], [IND_LOCK], [IND_ID_ACT]);
GO
