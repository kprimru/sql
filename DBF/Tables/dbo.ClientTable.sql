USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientTable]
(
        [CL_ID]            Int            Identity(1,1)   NOT NULL,
        [CL_NUM]           Int                            NOT NULL,
        [CL_PSEDO]         VarChar(50)                    NOT NULL,
        [CL_FULL_NAME]     VarChar(500)                   NOT NULL,
        [CL_SHORT_NAME]    VarChar(250)                       NULL,
        [CL_FOUNDING]      VarChar(300)                       NULL,
        [CL_EMAIL]         VarChar(150)                       NULL,
        [CL_INN]           VarChar(50)                        NULL,
        [CL_KPP]           VarChar(50)                        NULL,
        [CL_OKPO]          VarChar(50)                        NULL,
        [CL_OKONX]         VarChar(50)                        NULL,
        [CL_ACCOUNT]       VarChar(50)                        NULL,
        [CL_ID_BANK]       SmallInt                           NULL,
        [CL_ID_ACTIVITY]   SmallInt                           NULL,
        [CL_ID_FIN]        SmallInt                           NULL,
        [CL_ID_ORG]        SmallInt                           NULL,
        [CL_ID_SUBHOST]    SmallInt                           NULL,
        [CL_ID_TYPE]       SmallInt                           NULL,
        [CL_NOTE]          text                               NULL,
        [CL_NOTE2]         text                               NULL,
        [CL_PHONE]         VarChar(50)                        NULL,
        [CL_DATE]          DateTime                           NULL,
        [CL_ID_PAYER]      Int                                NULL,
        [CL_1C]            VarChar(50)                        NULL,
        [CL_ID_ORG_CALC]   SmallInt                           NULL,
        CONSTRAINT [PK_dbo.ClientTable] PRIMARY KEY NONCLUSTERED ([CL_ID]),
        CONSTRAINT [FK_dbo.ClientTable(CL_ID_ORG)_dbo.OrganizationTable(ORG_ID)] FOREIGN KEY  ([CL_ID_ORG]) REFERENCES [dbo].[OrganizationTable] ([ORG_ID]),
        CONSTRAINT [FK_dbo.ClientTable(CL_ID_SUBHOST)_dbo.SubhostTable(SH_ID)] FOREIGN KEY  ([CL_ID_SUBHOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_dbo.ClientTable(CL_ID_ACTIVITY)_dbo.ActivityTable(AC_ID)] FOREIGN KEY  ([CL_ID_ACTIVITY]) REFERENCES [dbo].[ActivityTable] ([AC_ID]),
        CONSTRAINT [FK_dbo.ClientTable(CL_ID_FIN)_dbo.FinancingTable(FIN_ID)] FOREIGN KEY  ([CL_ID_FIN]) REFERENCES [dbo].[FinancingTable] ([FIN_ID]),
        CONSTRAINT [FK_dbo.ClientTable(CL_ID_BANK)_dbo.BankTable(BA_ID)] FOREIGN KEY  ([CL_ID_BANK]) REFERENCES [dbo].[BankTable] ([BA_ID]),
        CONSTRAINT [FK_dbo.ClientTable(CL_ID_TYPE)_dbo.ClientTypeTable(CLT_ID)] FOREIGN KEY  ([CL_ID_TYPE]) REFERENCES [dbo].[ClientTypeTable] ([CLT_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ClientTable(CL_PSEDO,CL_ID,CL_FULL_NAME)] ON [dbo].[ClientTable] ([CL_PSEDO] ASC, [CL_ID] ASC, [CL_FULL_NAME] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTable(CL_1C)] ON [dbo].[ClientTable] ([CL_1C] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTable(CL_FULL_NAME)+(CL_ID)] ON [dbo].[ClientTable] ([CL_FULL_NAME] ASC) INCLUDE ([CL_ID]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTable(CL_ID,CL_PSEDO,CL_FULL_NAME)+(CL_INN)] ON [dbo].[ClientTable] ([CL_ID] ASC, [CL_PSEDO] ASC, [CL_FULL_NAME] ASC) INCLUDE ([CL_INN]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTable(CL_ID_TYPE)+(CL_ID,CL_PSEDO)] ON [dbo].[ClientTable] ([CL_ID_TYPE] ASC) INCLUDE ([CL_ID], [CL_PSEDO]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTable(CL_INN)+(CL_ID)] ON [dbo].[ClientTable] ([CL_INN] ASC) INCLUDE ([CL_ID]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ClientTable(CL_NUM)] ON [dbo].[ClientTable] ([CL_NUM] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ClientTable(CL_PSEDO)] ON [dbo].[ClientTable] ([CL_PSEDO] ASC);
GO
GRANT SELECT ON [dbo].[ClientTable] TO rl_all_r;
GRANT SELECT ON [dbo].[ClientTable] TO rl_client_fin_r;
GRANT SELECT ON [dbo].[ClientTable] TO rl_client_r;
GRANT SELECT ON [dbo].[ClientTable] TO rl_fin_r;
GRANT SELECT ON [dbo].[ClientTable] TO rl_to_r;
GO
