USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegNodeFullTable]
(
        [RN_ID]               Int             Identity(1,1)   NOT NULL,
        [RN_ID_SYSTEM]        SmallInt                        NOT NULL,
        [RN_DISTR_NUM]        Int                             NOT NULL,
        [RN_COMP_NUM]         TinyInt                         NOT NULL,
        [RN_ID_TYPE]          SmallInt                        NOT NULL,
        [RN_ID_TECH_TYPE]     SmallInt                            NULL,
        [RN_ID_NET]           SmallInt                        NOT NULL,
        [RN_SUBHOST]          Bit                             NOT NULL,
        [RN_ID_SUBHOST]       SmallInt                        NOT NULL,
        [RN_TRANSFER_COUNT]   SmallInt                        NOT NULL,
        [RN_TRANSFER_LEFT]    SmallInt                        NOT NULL,
        [RN_ID_STATUS]        SmallInt                        NOT NULL,
        [RN_REG_DATE]         SmallDateTime                   NOT NULL,
        [RN_FIRST_REG]        SmallDateTime                       NULL,
        [RN_COMMENT]          VarChar(255)                    NOT NULL,
        [RN_COMPLECT]         VarChar(50)                     NOT NULL,
        [RN_REPORT_CODE]      VarChar(10)                         NULL,
        [RN_REPORT_VALUE]     VarChar(50)                         NULL,
        [RN_SHORT]            VarChar(10)                         NULL,
        [RN_MAIN]             TinyInt                             NULL,
        [RN_OFFLINE]          VarChar(50)                         NULL,
        [RN_YUBIKEY]          VarChar(50)                         NULL,
        [RN_KRF]              VarChar(50)                         NULL,
        [RN_KRF1]             VarChar(50)                         NULL,
        [RN_PARAM]            VarChar(50)                         NULL,
        [RN_ODON]             VarChar(50)                         NULL,
        [RN_ODOFF]            VarChar(50)                         NULL,
        CONSTRAINT [PK_dbo.RegNodeFullTable] PRIMARY KEY NONCLUSTERED ([RN_ID]),
        CONSTRAINT [FK_dbo.RegNodeFullTable(RN_ID_SUBHOST)_dbo.SubhostTable(SH_ID)] FOREIGN KEY  ([RN_ID_SUBHOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_dbo.RegNodeFullTable(RN_ID_STATUS)_dbo.DistrStatusTable(DS_ID)] FOREIGN KEY  ([RN_ID_STATUS]) REFERENCES [dbo].[DistrStatusTable] ([DS_ID]),
        CONSTRAINT [FK_dbo.RegNodeFullTable(RN_ID_TYPE)_dbo.SystemTypeTable(SST_ID)] FOREIGN KEY  ([RN_ID_TYPE]) REFERENCES [dbo].[SystemTypeTable] ([SST_ID]),
        CONSTRAINT [FK_dbo.RegNodeFullTable(RN_ID_SYSTEM)_dbo.SystemTable(SYS_ID)] FOREIGN KEY  ([RN_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID]),
        CONSTRAINT [FK_dbo.RegNodeFullTable(RN_ID_TECH_TYPE)_dbo.TechnolTypeTable(TT_ID)] FOREIGN KEY  ([RN_ID_TECH_TYPE]) REFERENCES [dbo].[TechnolTypeTable] ([TT_ID]),
        CONSTRAINT [FK_dbo.RegNodeFullTable(RN_ID_NET)_dbo.SystemNetCountTable(SNC_ID)] FOREIGN KEY  ([RN_ID_NET]) REFERENCES [dbo].[SystemNetCountTable] ([SNC_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.RegNodeFullTable(RN_DISTR_NUM,RN_ID_SYSTEM,RN_COMP_NUM,RN_REG_DATE)] ON [dbo].[RegNodeFullTable] ([RN_DISTR_NUM] ASC, [RN_ID_SYSTEM] ASC, [RN_COMP_NUM] ASC, [RN_REG_DATE] ASC);
GO
