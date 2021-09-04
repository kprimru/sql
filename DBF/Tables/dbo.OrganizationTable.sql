USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrganizationTable]
(
        [ORG_ID]            SmallInt       Identity(1,1)   NOT NULL,
        [ORG_PSEDO]         VarChar(50)                        NULL,
        [ORG_FULL_NAME]     VarChar(250)                   NOT NULL,
        [ORG_SHORT_NAME]    VarChar(50)                    NOT NULL,
        [ORG_INDEX]         VarChar(50)                        NULL,
        [ORG_ID_STREET]     Int                                NULL,
        [ORG_HOME]          VarChar(100)                       NULL,
        [ORG_S_INDEX]       VarChar(50)                        NULL,
        [ORG_S_ID_STREET]   Int                                NULL,
        [ORG_S_HOME]        VarChar(100)                       NULL,
        [ORG_PHONE]         VarChar(50)                        NULL,
        [ORG_ID_BANK]       SmallInt                           NULL,
        [ORG_ACCOUNT]       VarChar(50)                        NULL,
        [ORG_LORO]          VarChar(50)                        NULL,
        [ORG_BIK]           VarChar(50)                        NULL,
        [ORG_INN]           VarChar(50)                        NULL,
        [ORG_KPP]           VarChar(50)                        NULL,
        [ORG_OKONH]         VarChar(50)                        NULL,
        [ORG_OKPO]          VarChar(50)                        NULL,
        [ORG_BUH_FAM]       VarChar(50)                        NULL,
        [ORG_BUH_NAME]      VarChar(50)                        NULL,
        [ORG_BUH_OTCH]      VarChar(50)                        NULL,
        [ORG_DIR_FAM]       VarChar(50)                        NULL,
        [ORG_DIR_NAME]      VarChar(50)                        NULL,
        [ORG_DIR_OTCH]      VarChar(50)                        NULL,
        [ORG_ACTIVE]        Bit                            NOT NULL,
        [ORG_LOGO]          varbinary                          NULL,
        [ORG_1C]            VarChar(10)                        NULL,
        [ORG_BILL_SHORT]    VarChar(128)                       NULL,
        [ORG_BILL_POS]      VarChar(128)                       NULL,
        [ORG_BILL_MEMO]     VarChar(128)                       NULL,
        [ORG_DIR_POS]       VarChar(250)                       NULL,
        [ORG_EMAIL]         VarChar(250)                       NULL,
        [EIS_CODE]          VarChar(100)                       NULL,
        CONSTRAINT [PK_dbo.OrganizationTable] PRIMARY KEY CLUSTERED ([ORG_ID]),
        CONSTRAINT [FK_dbo.OrganizationTable(ORG_ID_BANK)_dbo.BankTable(BA_ID)] FOREIGN KEY  ([ORG_ID_BANK]) REFERENCES [dbo].[BankTable] ([BA_ID]),
        CONSTRAINT [FK_dbo.OrganizationTable(ORG_ID_STREET)_dbo.StreetTable(ST_ID)] FOREIGN KEY  ([ORG_ID_STREET]) REFERENCES [dbo].[StreetTable] ([ST_ID]),
        CONSTRAINT [FK_dbo.OrganizationTable(ORG_S_ID_STREET)_dbo.StreetTable(ST_ID)] FOREIGN KEY  ([ORG_S_ID_STREET]) REFERENCES [dbo].[StreetTable] ([ST_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_U_ORG_SHORT] ON [dbo].[OrganizationTable] ([ORG_SHORT_NAME] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.OrganizationTable()] ON [dbo].[OrganizationTable] ([ORG_FULL_NAME] ASC);
GO
