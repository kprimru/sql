USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceFactMasterTable]
(
        [IFM_ID]            bigint          Identity(1,1)   NOT NULL,
        [IFM_DATE]          DateTime                        NOT NULL,
        [INS_ID]            Int                             NOT NULL,
        [ORG_ID]            SmallInt                        NOT NULL,
        [ORG_PSEDO]         VarChar(50)                     NOT NULL,
        [ORG_FULL_NAME]     VarChar(250)                    NOT NULL,
        [ORG_SHORT_NAME]    VarChar(50)                     NOT NULL,
        [ORG_ADDRESS]       VarChar(250)                    NOT NULL,
        [ORG_INN]           VarChar(50)                     NOT NULL,
        [ORG_KPP]           VarChar(50)                     NOT NULL,
        [INS_DATE]          SmallDateTime                   NOT NULL,
        [INS_NUM]           Int                             NOT NULL,
        [INS_NUM_YEAR]      VarChar(5)                      NOT NULL,
        [CL_ID]             Int                             NOT NULL,
        [CL_PSEDO]          VarChar(50)                     NOT NULL,
        [CL_FULL_NAME]      VarChar(500)                    NOT NULL,
        [CL_SHORT_NAME]     VarChar(150)                    NOT NULL,
        [CL_INN]            VarChar(50)                         NULL,
        [CL_KPP]            VarChar(50)                         NULL,
        [INS_CLIENT_ADDR]   VarChar(300)                        NULL,
        [INS_CONSIG_NAME]   VarChar(200)                        NULL,
        [INS_CONSIG_ADDR]   VarChar(300)                        NULL,
        [INS_DOC_STRING]    VarChar(200)                        NULL,
        [INS_STORNO]        Bit                                 NULL,
        [INS_COMMENT]       VarChar(200)                        NULL,
        [INS_PREPAY]        Bit                                 NULL,
        [ORG_DIR_SHORT]     VarChar(50)                     NOT NULL,
        [ORG_BUH_SHORT]     VarChar(50)                     NOT NULL,
        [INS_ID_TYPE]       SmallInt                            NULL,
        [INS_IDENT]         NVarChar(256)                       NULL,
        [ACT_DATE]          SmallDateTime                       NULL,
        CONSTRAINT [PK_dbo.InvoiceFactMasterTable] PRIMARY KEY CLUSTERED ([IFM_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.InvoiceFactMasterTable(CL_ID)] ON [dbo].[InvoiceFactMasterTable] ([CL_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.InvoiceFactMasterTable(IFM_DATE)] ON [dbo].[InvoiceFactMasterTable] ([IFM_DATE] ASC);
GO
