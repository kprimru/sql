USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientInnovation]
(
        [ID]              UniqueIdentifier      NOT NULL,
        [ID_CLIENT]       Int                   NOT NULL,
        [ID_INNOVATION]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_dbo.ClientInnovation] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientInnovation(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientInnovation(ID_INNOVATION)_dbo.Innovation(ID)] FOREIGN KEY  ([ID_INNOVATION]) REFERENCES [dbo].[Innovation] ([ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ClientInnovation(ID_CLIENT,ID_INNOVATION)] ON [dbo].[ClientInnovation] ([ID_CLIENT] ASC, [ID_INNOVATION] ASC);
GO
