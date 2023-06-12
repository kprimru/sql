USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientDistr]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_CLIENT]   Int                   NOT NULL,
        [ID_HOST]     Int                   NOT NULL,
        [ID_SYSTEM]   Int                   NOT NULL,
        [DISTR]       Int                   NOT NULL,
        [COMP]        TinyInt               NOT NULL,
        [ID_TYPE]     Int                   NOT NULL,
        [ID_NET]      Int                   NOT NULL,
        [ID_STATUS]   UniqueIdentifier      NOT NULL,
        [ON_DATE]     SmallDateTime             NULL,
        [OFF_DATE]    SmallDateTime             NULL,
        [STATUS]      TinyInt               NOT NULL,
        [BDATE]       DateTime              NOT NULL,
        [EDATE]       DateTime                  NULL,
        [UPD_USER]    NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientDistr] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientDistr(ID_NET)_dbo.DistrTypeTable(DistrTypeID)] FOREIGN KEY  ([ID_NET]) REFERENCES [dbo].[DistrTypeTable] ([DistrTypeID]),
        CONSTRAINT [FK_dbo.ClientDistr(ID_HOST)_dbo.Hosts(HostID)] FOREIGN KEY  ([ID_HOST]) REFERENCES [dbo].[Hosts] ([HostID]),
        CONSTRAINT [FK_dbo.ClientDistr(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientDistr(ID_STATUS)_dbo.DistrStatus(DS_ID)] FOREIGN KEY  ([ID_STATUS]) REFERENCES [dbo].[DistrStatus] ([DS_ID]),
        CONSTRAINT [FK_dbo.ClientDistr(ID_SYSTEM)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_dbo.ClientDistr(ID_TYPE)_dbo.SystemTypeTable(SystemTypeID)] FOREIGN KEY  ([ID_TYPE]) REFERENCES [dbo].[SystemTypeTable] ([SystemTypeID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDistr(DISTR,ID_HOST,COMP)+(ID_CLIENT,STATUS)] ON [dbo].[ClientDistr] ([DISTR] ASC, [ID_HOST] ASC, [COMP] ASC) INCLUDE ([ID_CLIENT], [STATUS]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDistr(ID_CLIENT,STATUS)] ON [dbo].[ClientDistr] ([ID_CLIENT] ASC, [STATUS] ASC);
GO
