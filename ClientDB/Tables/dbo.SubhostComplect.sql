USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubhostComplect]
(
        [SC_ID]           UniqueIdentifier      NOT NULL,
        [SC_ID_SUBHOST]   UniqueIdentifier      NOT NULL,
        [SC_COMPLECT]     VarChar(50)               NULL,
        [SC_ACTIVE]       Bit                       NULL,
        [SC_ID_HOST]      Int                       NULL,
        [SC_DISTR]        Int                       NULL,
        [SC_COMP]         TinyInt                   NULL,
        [SC_REG]          Bit                       NULL,
        [SC_USR]          Bit                       NULL,
        CONSTRAINT [PK_dbo.SubhostComplect] PRIMARY KEY CLUSTERED ([SC_ID]),
        CONSTRAINT [FK_dbo.SubhostComplect(SC_ID_SUBHOST)_dbo.Subhost(SH_ID)] FOREIGN KEY  ([SC_ID_SUBHOST]) REFERENCES [dbo].[Subhost] ([SH_ID]),
        CONSTRAINT [FK_dbo.SubhostComplect(SC_ID_HOST)_dbo.Hosts(HostID)] FOREIGN KEY  ([SC_ID_HOST]) REFERENCES [dbo].[Hosts] ([HostID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.SubhostComplect(SC_DISTR,SC_ID_HOST,SC_COMP)+(SC_ID_SUBHOST,SC_REG,SC_USR)] ON [dbo].[SubhostComplect] ([SC_DISTR] ASC, [SC_ID_HOST] ASC, [SC_COMP] ASC) INCLUDE ([SC_ID_SUBHOST], [SC_REG], [SC_USR]);
GO
