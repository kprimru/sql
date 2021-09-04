USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostCompensationTable]
(
        [SCP_ID]           Int            Identity(1,1)   NOT NULL,
        [SCP_ID_SUBHOST]   SmallInt                       NOT NULL,
        [SCP_ID_PERIOD]    SmallInt                       NOT NULL,
        [SCP_ID_SYSTEM]    SmallInt                       NOT NULL,
        [SCP_ID_TYPE]      SmallInt                       NOT NULL,
        [SCP_ID_NET]       SmallInt                       NOT NULL,
        [SCP_ID_TECH]      SmallInt                           NULL,
        [SCP_DISTR]        Int                            NOT NULL,
        [SCP_COMP]         TinyInt                        NOT NULL,
        [SCP_COMMENT]      VarChar(100)                   NOT NULL,
        CONSTRAINT [PK_Subhost.SubhostCompensationTable] PRIMARY KEY CLUSTERED ([SCP_ID]),
        CONSTRAINT [FK_Subhost.SubhostCompensationTable(SCP_ID_SUBHOST)_Subhost.SubhostTable(SH_ID)] FOREIGN KEY  ([SCP_ID_SUBHOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_Subhost.SubhostCompensationTable(SCP_ID_NET)_Subhost.SystemNetTable(SN_ID)] FOREIGN KEY  ([SCP_ID_NET]) REFERENCES [dbo].[SystemNetTable] ([SN_ID]),
        CONSTRAINT [FK_Subhost.SubhostCompensationTable(SCP_ID_SYSTEM)_Subhost.SystemTable(SYS_ID)] FOREIGN KEY  ([SCP_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID]),
        CONSTRAINT [FK_Subhost.SubhostCompensationTable(SCP_ID_TYPE)_Subhost.SystemTypeTable(SST_ID)] FOREIGN KEY  ([SCP_ID_TYPE]) REFERENCES [dbo].[SystemTypeTable] ([SST_ID]),
        CONSTRAINT [FK_Subhost.SubhostCompensationTable(SCP_ID_PERIOD)_Subhost.PeriodTable(PR_ID)] FOREIGN KEY  ([SCP_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Subhost.SubhostCompensationTable(SCP_ID_PERIOD,SCP_ID_SYSTEM,SCP_DISTR,SCP_COMP)] ON [Subhost].[SubhostCompensationTable] ([SCP_ID_PERIOD] ASC, [SCP_ID_SYSTEM] ASC, [SCP_DISTR] ASC, [SCP_COMP] ASC);
GO
