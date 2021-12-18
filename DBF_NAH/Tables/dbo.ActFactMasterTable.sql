USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActFactMasterTable]
(
        [AFM_ID]             bigint          Identity(1,1)   NOT NULL,
        [AFM_DATE]           DateTime                        NOT NULL,
        [CL_ID]              Int                             NOT NULL,
        [CL_PSEDO]           VarChar(50)                     NOT NULL,
        [CL_FULL_NAME]       VarChar(250)                    NOT NULL,
        [CL_SHORT_NAME]      VarChar(200)                    NOT NULL,
        [CL_FOUNDING]        VarChar(500)                        NULL,
        [CO_ID]              Int                             NOT NULL,
        [CO_NUM]             VarChar(500)                    NOT NULL,
        [CO_DATE]            SmallDateTime                   NOT NULL,
        [CK_HEADER]          VarChar(50)                         NULL,
        [CK_CENTER]          VarChar(50)                         NULL,
        [CK_FOOTER]          VarChar(50)                         NULL,
        [POS_NAME]           VarChar(250)                        NULL,
        [PER_FAM]            VarChar(250)                        NULL,
        [PER_NAME]           VarChar(150)                        NULL,
        [PER_OTCH]           VarChar(150)                        NULL,
        [ORG_ID]             SmallInt                        NOT NULL,
        [ORG_FULL_NAME]      VarChar(250)                    NOT NULL,
        [ORG_SHORT_NAME]     VarChar(150)                    NOT NULL,
        [ORG_INN]            VarChar(50)                     NOT NULL,
        [ORG_KPP]            VarChar(50)                     NOT NULL,
        [ORG_ACCOUNT]        VarChar(50)                     NOT NULL,
        [ORG_LORO]           VarChar(50)                     NOT NULL,
        [ORG_BIK]            VarChar(50)                     NOT NULL,
        [ORG_DIR_FAM]        VarChar(50)                     NOT NULL,
        [ORG_DIR_NAME]       VarChar(50)                     NOT NULL,
        [ORG_DIR_OTCH]       VarChar(50)                     NOT NULL,
        [ORG_DIR_SHORT]      VarChar(50)                     NOT NULL,
        [BA_NAME]            VarChar(150)                    NOT NULL,
        [PR_MONTH]           VarChar(15)                     NOT NULL,
        [PR_END_DATE]        SmallDateTime                   NOT NULL,
        [ACT_ID]             Int                                 NULL,
        [ACT_TO]             Bit                                 NULL,
        [TAX_STR]            decimal                             NULL,
        [CO_KEY]             VarChar(256)                        NULL,
        [CO_NUM_FROM]        VarChar(256)                        NULL,
        [CO_NUM_TO]          VarChar(256)                        NULL,
        [CO_EMAIL]           VarChar(256)                        NULL,
        [IsOnline]           Bit                                 NULL,
        [IsLongService]      Bit                                 NULL,
        [CK_CREATIVE]        VarChar(50)                         NULL,
        [CK_PREPOSITIONAL]   VarChar(50)                         NULL,
        CONSTRAINT [PK_dbo.ActFactMasterTable] PRIMARY KEY CLUSTERED ([AFM_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ActFactMasterTable(AFM_DATE,CL_ID)] ON [dbo].[ActFactMasterTable] ([AFM_DATE] ASC, [CL_ID] ASC);
GO
