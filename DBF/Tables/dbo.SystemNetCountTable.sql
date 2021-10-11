USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemNetCountTable]
(
        [SNC_ID]          SmallInt      Identity(1,1)   NOT NULL,
        [SNC_ID_SN]       SmallInt                      NOT NULL,
        [SNC_NET_COUNT]   SmallInt                      NOT NULL,
        [SNC_TECH]        SmallInt                          NULL,
        [SNC_ACTIVE]      Bit                           NOT NULL,
        [SNC_SHORT]       VarChar(50)                       NULL,
        [SNC_ODON]        SmallInt                          NULL,
        [SNC_ODOFF]       SmallInt                          NULL,
        CONSTRAINT [PK_dbo.SystemNetCountTable] PRIMARY KEY CLUSTERED ([SNC_ID]),
        CONSTRAINT [FK_dbo.SystemNetCountTable(SNC_ID_SN)_dbo.SystemNetTable(SN_ID)] FOREIGN KEY  ([SNC_ID_SN]) REFERENCES [dbo].[SystemNetTable] ([SN_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.SystemNetCountTable(SNC_ID_SN)] ON [dbo].[SystemNetCountTable] ([SNC_ID_SN] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.SystemNetCountTable(SNC_NET_COUNT,SNC_TECH,SNC_ODON,SNC_ODOFF)+(SNC_ID_SN)] ON [dbo].[SystemNetCountTable] ([SNC_NET_COUNT] ASC, [SNC_TECH] ASC, [SNC_ODON] ASC, [SNC_ODOFF] ASC) INCLUDE ([SNC_ID_SN]);
GO
GRANT SELECT ON [dbo].[SystemNetCountTable] TO rl_reg_node_report_r;
GO
