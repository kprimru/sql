USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegNodeTable]
(
        [RN_SYS_NAME]         VarChar(20)            NULL,
        [RN_DISTR_NUM]        Int                    NULL,
        [RN_COMP_NUM]         TinyInt                NULL,
        [RN_DISTR_TYPE]       VarChar(20)            NULL,
        [RN_TECH_TYPE]        VarChar(20)            NULL,
        [RN_NET_COUNT]        SmallInt               NULL,
        [RN_SUBHOST]          SmallInt               NULL,
        [RN_TRANSFER_COUNT]   SmallInt               NULL,
        [RN_TRANSFER_LEFT]    SmallInt               NULL,
        [RN_SERVICE]          SmallInt               NULL,
        [RN_REG_DATE]         SmallDateTime          NULL,
        [RN_FIRST_REG]        SmallDateTime          NULL,
        [RN_COMMENT]          VarChar(255)           NULL,
        [RN_COMPLECT]         VarChar(50)            NULL,
        [RN_REPORT_CODE]      VarChar(10)            NULL,
        [RN_REPORT_VALUE]     VarChar(50)            NULL,
        [RN_SHORT]            VarChar(10)            NULL,
        [RN_MAIN]             TinyInt                NULL,
        [RN_SUB]              TinyInt                NULL,
        [RN_OFFLINE]          VarChar(50)            NULL,
        [RN_YUBIKEY]          VarChar(50)            NULL,
        [RN_KRF]              VarChar(50)            NULL,
        [RN_KRF1]             VarChar(50)            NULL,
        [RN_PARAM]            VarChar(50)            NULL,
        [RN_ODON]             VarChar(50)            NULL,
        [RN_ODOFF]            VarChar(50)            NULL,
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.RegNodeTable(RN_DISTR_NUM,RN_SYS_NAME,RN_COMP_NUM,RN_SERVICE)] ON [dbo].[RegNodeTable] ([RN_DISTR_NUM] ASC, [RN_SYS_NAME] ASC, [RN_COMP_NUM] ASC, [RN_SERVICE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.RegNodeTable(RN_COMPLECT)+(RN_SYS_NAME,RN_DISTR_NUM,RN_COMP_NUM)] ON [dbo].[RegNodeTable] ([RN_COMPLECT] ASC) INCLUDE ([RN_SYS_NAME], [RN_DISTR_NUM], [RN_COMP_NUM]);
CREATE NONCLUSTERED INDEX [IX_dbo.RegNodeTable(RN_SERVICE)+(RN_SYS_NAME,RN_DISTR_NUM,RN_COMP_NUM)] ON [dbo].[RegNodeTable] ([RN_SERVICE] ASC) INCLUDE ([RN_SYS_NAME], [RN_DISTR_NUM], [RN_COMP_NUM]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.RegNodeTable(RN_SYS_NAME,RN_DISTR_NUM,RN_COMP_NUM)] ON [dbo].[RegNodeTable] ([RN_SYS_NAME] ASC, [RN_DISTR_NUM] ASC, [RN_COMP_NUM] ASC);
GO
