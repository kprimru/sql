USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConsignmentTable]
(
        [CSG_ID]                Int             Identity(1,1)   NOT NULL,
        [CSG_ID_MASTER]         Int                                 NULL,
        [CSG_ID_ORG]            SmallInt                        NOT NULL,
        [CSG_ID_CLIENT]         Int                                 NULL,
        [CSG_CONSIGN_NAME]      VarChar(250)                        NULL,
        [CSG_CONSIGN_ADDRESS]   VarChar(250)                        NULL,
        [CSG_CONSIGN_OKPO]      VarChar(50)                         NULL,
        [CSG_CONSIGN_INN]       VarChar(50)                         NULL,
        [CSG_CONSIGN_KPP]       VarChar(50)                         NULL,
        [CSG_CLIENT_NAME]       VarChar(250)                        NULL,
        [CSG_CLIENT_ADDRESS]    VarChar(250)                        NULL,
        [CSG_CLIENT_PHONE]      VarChar(50)                         NULL,
        [CSG_CLIENT_BANK]       VarChar(500)                        NULL,
        [CSG_FOUND]             VarChar(100)                        NULL,
        [CSG_NUM]               Int                                 NULL,
        [CSG_DATE]              SmallDateTime                   NOT NULL,
        [CSG_ID_INVOICE]        Int                                 NULL,
        [CSG]                   Bit                                 NULL,
        [CSG_PRINT]             Bit                                 NULL,
        [CSG_PRINT_DATE]        DateTime                            NULL,
        [CSG_SIGN]              SmallDateTime                       NULL,
        [CSG_ID_PAYER]          Int                                 NULL,
        [CSG_STATUS]            TinyInt                         NOT NULL,
        [CSG_UPD_DATE]          DateTime                        NOT NULL,
        [CSG_UPD_USER]          NVarChar(256)                   NOT NULL,
        CONSTRAINT [PK_dbo.ConsignmentTable] PRIMARY KEY NONCLUSTERED ([CSG_ID]),
        CONSTRAINT [FK_dbo.ConsignmentTable(CSG_ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([CSG_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID]),
        CONSTRAINT [FK_dbo.ConsignmentTable(CSG_ID_INVOICE)_dbo.InvoiceSaleTable(INS_ID)] FOREIGN KEY  ([CSG_ID_INVOICE]) REFERENCES [dbo].[InvoiceSaleTable] ([INS_ID]),
        CONSTRAINT [FK_dbo.ConsignmentTable(CSG_ID_ORG)_dbo.OrganizationTable(ORG_ID)] FOREIGN KEY  ([CSG_ID_ORG]) REFERENCES [dbo].[OrganizationTable] ([ORG_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ConsignmentTable(CSG_ID_CLIENT,CSG_ID,CSG_DATE)] ON [dbo].[ConsignmentTable] ([CSG_ID_CLIENT] ASC, [CSG_ID] ASC, [CSG_DATE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ConsignmentTable(CSG_DATE)+(CSG_ID,CSG_ID_CLIENT,CSG_ID_INVOICE)] ON [dbo].[ConsignmentTable] ([CSG_DATE] ASC) INCLUDE ([CSG_ID], [CSG_ID_CLIENT], [CSG_ID_INVOICE]);
CREATE NONCLUSTERED INDEX [IX_dbo.ConsignmentTable(CSG_ID,CSG_ID_ORG)] ON [dbo].[ConsignmentTable] ([CSG_ID] ASC, [CSG_ID_ORG] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ConsignmentTable(CSG_ID_INVOICE)+(CSG_ID)] ON [dbo].[ConsignmentTable] ([CSG_ID_INVOICE] ASC) INCLUDE ([CSG_ID]);
GO
