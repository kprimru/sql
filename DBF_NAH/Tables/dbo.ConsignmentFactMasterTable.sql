USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConsignmentFactMasterTable]
(
        [CFM_ID]                bigint          Identity(1,1)   NOT NULL,
        [CFM_NUM]               VarChar(50)                         NULL,
        [CFM_FACT_DATE]         DateTime                            NULL,
        [CFM_DATE]              SmallDateTime                   NOT NULL,
        [CL_ID]                 Int                                 NULL,
        [CFM_CONSIGN_NAME]      VarChar(500)                        NULL,
        [CFM_CONSIGN_ADDRESS]   VarChar(500)                        NULL,
        [CFM_CONSIGN_INN]       VarChar(50)                         NULL,
        [CFM_CONSIGN_KPP]       VarChar(50)                         NULL,
        [CFM_CONSIGN_OKPO]      VarChar(50)                         NULL,
        [CFM_CLIENT_NAME]       VarChar(500)                        NULL,
        [CFM_CLIENT_ADDRESS]    VarChar(500)                        NULL,
        [CFM_CLIENT_PHONE]      VarChar(50)                         NULL,
        [CFM_CLIENT_BANK]       VarChar(500)                        NULL,
        [CFM_FOUND]             VarChar(150)                        NULL,
        [ORG_ID]                SmallInt                            NULL,
        [ORG_SHORT_NAME]        VarChar(250)                        NULL,
        [ORG_ADDRESS]           VarChar(150)                        NULL,
        [ORG_INN]               VarChar(50)                         NULL,
        [ORG_KPP]               VarChar(50)                         NULL,
        [ORG_BANK]              VarChar(150)                        NULL,
        [ORG_ACCOUNT]           VarChar(50)                         NULL,
        [ORG_LORO]              VarChar(50)                         NULL,
        [ORG_BIK]               VarChar(50)                         NULL,
        [ORG_OKPO]              VarChar(50)                         NULL,
        [ORG_BUH_SHORT]         VarChar(100)                        NULL,
        [ORG_DIR_SHORT]         VarChar(100)                        NULL,
        CONSTRAINT [PK_dbo.ConsignmentFactMasterTable] PRIMARY KEY NONCLUSTERED ([CFM_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ConsignmentFactMasterTable(CL_ID,CFM_DATE,CFM_ID)] ON [dbo].[ConsignmentFactMasterTable] ([CL_ID] ASC, [CFM_DATE] ASC, [CFM_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ConsignmentFactMasterTable(CFM_DATE)+(CFM_ID)] ON [dbo].[ConsignmentFactMasterTable] ([CFM_DATE] ASC) INCLUDE ([CFM_ID]);
CREATE NONCLUSTERED INDEX [IX_dbo.ConsignmentFactMasterTable(CFM_FACT_DATE,CFM_DATE,CL_ID)] ON [dbo].[ConsignmentFactMasterTable] ([CFM_FACT_DATE] ASC, [CFM_DATE] ASC, [CL_ID] ASC);
GO
