USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceSaleTable]
(
        [INS_ID]             Int             Identity(1,1)   NOT NULL,
        [INS_ID_MASTER]      Int                                 NULL,
        [INS_ID_ORG]         SmallInt                        NOT NULL,
        [INS_DATE]           SmallDateTime                       NULL,
        [INS_NUM]            Int                                 NULL,
        [INS_NUM_YEAR]       VarChar(5)                          NULL,
        [INS_ID_CLIENT]      Int                                 NULL,
        [INS_CLIENT_PSEDO]   VarChar(100)                        NULL,
        [INS_CLIENT_NAME]    VarChar(500)                        NULL,
        [INS_CLIENT_ADDR]    VarChar(500)                        NULL,
        [INS_CONSIG_NAME]    VarChar(500)                        NULL,
        [INS_CONSIG_ADDR]    VarChar(500)                        NULL,
        [INS_CLIENT_INN]     VarChar(50)                         NULL,
        [INS_CLIENT_KPP]     VarChar(50)                         NULL,
        [INS_ID_INCOME]      Int                                 NULL,
        [INS_INCOME_DATE]    SmallDateTime                       NULL,
        [INS_DOC_STRING]     VarChar(500)                        NULL,
        [INS_STORNO]         Bit                                 NULL,
        [INS_COMMENT]        VarChar(200)                        NULL,
        [INS_PREPAY]         Bit                                 NULL,
        [INS_RESERVE]        Bit                                 NULL,
        [INS_ID_TYPE]        SmallInt                            NULL,
        [INS_CREATE_DATE]    DateTime                            NULL,
        [INS_ID_PAYER]       Int                                 NULL,
        [INS_STATUS]         TinyInt                         NOT NULL,
        [INS_UPD_DATE]       DateTime                        NOT NULL,
        [INS_UPD_USER]       NVarChar(256)                   NOT NULL,
        [INS_IDENT]          NVarChar(256)                       NULL,
        CONSTRAINT [PK_dbo.InvoiceSaleTable] PRIMARY KEY NONCLUSTERED ([INS_ID]),
        CONSTRAINT [FK_dbo.InvoiceSaleTable(INS_ID_ORG)_dbo.OrganizationTable(ORG_ID)] FOREIGN KEY  ([INS_ID_ORG]) REFERENCES [dbo].[OrganizationTable] ([ORG_ID]),
        CONSTRAINT [FK_dbo.InvoiceSaleTable(INS_ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([INS_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.InvoiceSaleTable(INS_ID_CLIENT,INS_ID)] ON [dbo].[InvoiceSaleTable] ([INS_ID_CLIENT] ASC, [INS_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.InvoiceSaleTable(INS_DATE,INS_ID)+INCL] ON [dbo].[InvoiceSaleTable] ([INS_DATE] ASC, [INS_ID] ASC) INCLUDE ([INS_ID_ORG], [INS_NUM], [INS_NUM_YEAR], [INS_ID_CLIENT], [INS_INCOME_DATE], [INS_ID_TYPE]);
CREATE NONCLUSTERED INDEX [IX_dbo.InvoiceSaleTable(INS_ID_ORG,INS_DATE)+(INS_ID,INS_ID_CLIENT,INS_ID_TYPE)] ON [dbo].[InvoiceSaleTable] ([INS_ID_ORG] ASC, [INS_DATE] ASC) INCLUDE ([INS_ID], [INS_ID_CLIENT], [INS_ID_TYPE]);
CREATE NONCLUSTERED INDEX [IX_dbo.InvoiceSaleTable(INS_ID_ORG,INS_NUM_YEAR)+(INS_NUM)] ON [dbo].[InvoiceSaleTable] ([INS_ID_ORG] ASC, [INS_NUM_YEAR] ASC) INCLUDE ([INS_NUM]);
CREATE NONCLUSTERED INDEX [IX_dbo.InvoiceSaleTable(INS_NUM)+(INS_ID,INS_DATE,INS_NUM_YEAR,INS_ID_CLIENT)] ON [dbo].[InvoiceSaleTable] ([INS_NUM] ASC) INCLUDE ([INS_ID], [INS_DATE], [INS_NUM_YEAR], [INS_ID_CLIENT]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.InvoiceSaleTable(INS_ID)+(INS_NUM,INS_NUM_YEAR)] ON [dbo].[InvoiceSaleTable] ([INS_ID] ASC) INCLUDE ([INS_NUM], [INS_NUM_YEAR]);
GO
GRANT SELECT ON [dbo].[InvoiceSaleTable] TO rl_all_r;
GO
