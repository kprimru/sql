USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [USR].[USRData]
(
        [UD_ID]          Int           Identity(1,1)   NOT NULL,
        [UD_COMPLECT]    VarChar(50)                       NULL,
        [UD_ID_CLIENT]   Int                               NULL,
        [UD_ACTIVE]      Bit                           NOT NULL,
        [UD_ID_HOST]     Int                               NULL,
        [UD_DISTR]       Int                               NULL,
        [UD_COMP]        TinyInt                           NULL,
        CONSTRAINT [PK_USR.USRData] PRIMARY KEY NONCLUSTERED ([UD_ID]),
        CONSTRAINT [FK_USR.USRData(UD_ID_CLIENT)_USR.ClientTable(ClientID)] FOREIGN KEY  ([UD_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_USR.USRData(UD_ID_HOST)_USR.Hosts(HostID)] FOREIGN KEY  ([UD_ID_HOST]) REFERENCES [dbo].[Hosts] ([HostID])
);
GO
CREATE CLUSTERED INDEX [IC_USR.USRData(UD_ID_CLIENT,UD_ACTIVE)] ON [USR].[USRData] ([UD_ID_CLIENT] ASC, [UD_ACTIVE] ASC);
CREATE NONCLUSTERED INDEX [IX_USR.USRData(UD_ACTIVE)+(UD_ID_CLIENT,UD_COMPLECT,UD_ID)] ON [USR].[USRData] ([UD_ACTIVE] ASC) INCLUDE ([UD_ID_CLIENT], [UD_COMPLECT], [UD_ID]);
CREATE NONCLUSTERED INDEX [IX_USR.USRData(UD_ACTIVE,UD_ID_HOST)+(UD_ID,UD_DISTR,UD_COMP)] ON [USR].[USRData] ([UD_ACTIVE] ASC, [UD_ID_HOST] ASC) INCLUDE ([UD_ID], [UD_DISTR], [UD_COMP]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_USR.USRData(UD_DISTR,UD_ID_HOST,UD_COMP)+(UD_ID,UD_ACTIVE)] ON [USR].[USRData] ([UD_DISTR] ASC, [UD_ID_HOST] ASC, [UD_COMP] ASC) INCLUDE ([UD_ID], [UD_ACTIVE]);
GO
GRANT SELECT ON [USR].[USRData] TO claim_view;
GO
