USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[RegNodeSubhostTable]
(
        [RNS_ID]            bigint         Identity(1,1)   NOT NULL,
        [RNS_ID_PERIOD]     SmallInt                       NOT NULL,
        [RNS_ID_HOST]       SmallInt                       NOT NULL,
        [RNS_ID_SYSTEM]     SmallInt                       NOT NULL,
        [RNS_ID_TYPE]       SmallInt                       NOT NULL,
        [RNS_ID_TECH]       SmallInt                           NULL,
        [RNS_ID_NET]        SmallInt                       NOT NULL,
        [RNS_DISTR]         Int                            NOT NULL,
        [RNS_COMP]          TinyInt                        NOT NULL,
        [RNS_COMMENT]       VarChar(100)                       NULL,
        [RNS_ID_OLD_SYS]    SmallInt                           NULL,
        [RNS_ID_NEW_SYS]    SmallInt                           NULL,
        [RNS_ID_OLD_NET]    SmallInt                           NULL,
        [RNS_ID_NEW_NET]    SmallInt                           NULL,
        [RNS_ID_OLD_TECH]   SmallInt                           NULL,
        [RNS_ID_NEW_TECH]   SmallInt                           NULL,
        CONSTRAINT [PK_Subhost.RegNodeSubhostTable] PRIMARY KEY CLUSTERED ([RNS_ID]),
        CONSTRAINT [FK_Subhost.RegNodeSubhostTable(RNS_ID_NET)_Subhost.SystemNetTable(SN_ID)] FOREIGN KEY  ([RNS_ID_NET]) REFERENCES [dbo].[SystemNetTable] ([SN_ID]),
        CONSTRAINT [FK_Subhost.RegNodeSubhostTable(RNS_ID_NEW_NET)_Subhost.SystemNetTable(SN_ID)] FOREIGN KEY  ([RNS_ID_NEW_NET]) REFERENCES [dbo].[SystemNetTable] ([SN_ID]),
        CONSTRAINT [FK_Subhost.RegNodeSubhostTable(RNS_ID_OLD_NET)_Subhost.SystemNetTable(SN_ID)] FOREIGN KEY  ([RNS_ID_OLD_NET]) REFERENCES [dbo].[SystemNetTable] ([SN_ID]),
        CONSTRAINT [FK_Subhost.RegNodeSubhostTable(RNS_ID_SYSTEM)_Subhost.SystemTable(SYS_ID)] FOREIGN KEY  ([RNS_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID]),
        CONSTRAINT [FK_Subhost.RegNodeSubhostTable(RNS_ID_NEW_SYS)_Subhost.SystemTable(SYS_ID)] FOREIGN KEY  ([RNS_ID_NEW_SYS]) REFERENCES [dbo].[SystemTable] ([SYS_ID]),
        CONSTRAINT [FK_Subhost.RegNodeSubhostTable(RNS_ID_OLD_SYS)_Subhost.SystemTable(SYS_ID)] FOREIGN KEY  ([RNS_ID_OLD_SYS]) REFERENCES [dbo].[SystemTable] ([SYS_ID]),
        CONSTRAINT [FK_Subhost.RegNodeSubhostTable(RNS_ID_TECH)_Subhost.TechnolTypeTable(TT_ID)] FOREIGN KEY  ([RNS_ID_TECH]) REFERENCES [dbo].[TechnolTypeTable] ([TT_ID]),
        CONSTRAINT [FK_Subhost.RegNodeSubhostTable(RNS_ID_HOST)_Subhost.SubhostTable(SH_ID)] FOREIGN KEY  ([RNS_ID_HOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_Subhost.RegNodeSubhostTable(RNS_ID_PERIOD)_Subhost.PeriodTable(PR_ID)] FOREIGN KEY  ([RNS_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_Subhost.RegNodeSubhostTable(RNS_ID_TYPE)_Subhost.SystemTypeTable(SST_ID)] FOREIGN KEY  ([RNS_ID_TYPE]) REFERENCES [dbo].[SystemTypeTable] ([SST_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Subhost.RegNodeSubhostTable(RNS_ID_PERIOD,RNS_ID_SYSTEM,RNS_DISTR,RNS_COMP)] ON [Subhost].[RegNodeSubhostTable] ([RNS_ID_PERIOD] ASC, [RNS_ID_SYSTEM] ASC, [RNS_DISTR] ASC, [RNS_COMP] ASC);
GO
