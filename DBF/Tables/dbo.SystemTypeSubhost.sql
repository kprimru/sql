USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemTypeSubhost]
(
        [STS_ID]           Int        Identity(1,1)   NOT NULL,
        [STS_ID_SUBHOST]   SmallInt                   NOT NULL,
        [STS_ID_TYPE]      SmallInt                   NOT NULL,
        [STS_ID_HOST]      SmallInt                       NULL,
        [STS_ID_DHOST]     SmallInt                       NULL,
        CONSTRAINT [PK_dbo.SystemTypeSubhost] PRIMARY KEY CLUSTERED ([STS_ID]),
        CONSTRAINT [FK_dbo.SystemTypeSubhost(STS_ID_SUBHOST)_dbo.SubhostTable(SH_ID)] FOREIGN KEY  ([STS_ID_SUBHOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_dbo.SystemTypeSubhost(STS_ID_TYPE)_dbo.SystemTypeTable(SST_ID)] FOREIGN KEY  ([STS_ID_TYPE]) REFERENCES [dbo].[SystemTypeTable] ([SST_ID]),
        CONSTRAINT [FK_dbo.SystemTypeSubhost(STS_ID_HOST)_dbo.SystemTypeTable(SST_ID)] FOREIGN KEY  ([STS_ID_HOST]) REFERENCES [dbo].[SystemTypeTable] ([SST_ID]),
        CONSTRAINT [FK_dbo.SystemTypeSubhost(STS_ID_DHOST)_dbo.SystemTypeTable(SST_ID)] FOREIGN KEY  ([STS_ID_DHOST]) REFERENCES [dbo].[SystemTypeTable] ([SST_ID])
);GO
