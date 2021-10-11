USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillFactMasterTable]
(
        [BFM_ID]           bigint          Identity(1,1)   NOT NULL,
        [BFM_DATE]         DateTime                        NOT NULL,
        [BFM_NUM]          VarChar(50)                         NULL,
        [BFM_ID_PERIOD]    SmallInt                            NULL,
        [BILL_DATE]        SmallDateTime                       NULL,
        [CL_ID]            Int                             NOT NULL,
        [CL_SHORT_NAME]    VarChar(500)                    NOT NULL,
        [CL_CITY]          VarChar(100)                        NULL,
        [CL_ADDRESS]       VarChar(250)                        NULL,
        [ORG_ID]           SmallInt                        NOT NULL,
        [ORG_SHORT_NAME]   VarChar(100)                    NOT NULL,
        [ORG_INDEX]        VarChar(50)                     NOT NULL,
        [ORG_ADDRESS]      VarChar(250)                    NOT NULL,
        [ORG_PHONE]        VarChar(100)                    NOT NULL,
        [ORG_ACCOUNT]      VarChar(50)                     NOT NULL,
        [ORG_LORO]         VarChar(50)                     NOT NULL,
        [ORG_BIK]          VarChar(50)                     NOT NULL,
        [ORG_INN]          VarChar(50)                     NOT NULL,
        [ORG_KPP]          VarChar(50)                     NOT NULL,
        [ORG_OKONH]        VarChar(50)                     NOT NULL,
        [ORG_OKPO]         VarChar(50)                     NOT NULL,
        [ORG_BUH_SHORT]    VarChar(150)                    NOT NULL,
        [BA_NAME]          VarChar(150)                        NULL,
        [BA_CITY]          VarChar(150)                        NULL,
        [CO_NUM]           VarChar(500)                        NULL,
        [CO_DATE]          SmallDateTime                       NULL,
        [CO_ID]            Int                                 NULL,
        [SO_ID]            SmallInt                            NULL,
        [CK_HEADER]        VarChar(150)                        NULL,
        [ORG_BILL_SHORT]   VarChar(128)                        NULL,
        [ORG_BILL_POS]     VarChar(128)                        NULL,
        [ORG_BILL_NOTE]    VarChar(128)                        NULL,
        CONSTRAINT [PK_dbo.BillFactMasterTable] PRIMARY KEY NONCLUSTERED ([BFM_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.BillFactMasterTable(BFM_DATE,BFM_ID)] ON [dbo].[BillFactMasterTable] ([BFM_DATE] ASC, [BFM_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.BillFactMasterTable(BFM_ID_PERIOD,ORG_ID)+(BFM_NUM,BFM_DATE)] ON [dbo].[BillFactMasterTable] ([BFM_ID_PERIOD] ASC, [ORG_ID] ASC) INCLUDE ([BFM_NUM], [BFM_DATE]);
CREATE NONCLUSTERED INDEX [IX_dbo.BillFactMasterTable(BFM_NUM)] ON [dbo].[BillFactMasterTable] ([BFM_NUM] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.BillFactMasterTable(CL_ID,BFM_ID_PERIOD)+(BFM_DATE,BFM_NUM,ORG_ID,BILL_DATE,CO_NUM,SO_ID)] ON [dbo].[BillFactMasterTable] ([CL_ID] ASC, [BFM_ID_PERIOD] ASC) INCLUDE ([BFM_DATE], [BFM_NUM], [ORG_ID], [BILL_DATE], [CO_NUM], [SO_ID]);
GO
GRANT SELECT ON [dbo].[BillFactMasterTable] TO rl_all_r;
GO
