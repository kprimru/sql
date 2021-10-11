USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientService]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_CLIENT]    Int                   NOT NULL,
        [ID_SERVICE]   Int                   NOT NULL,
        [DATE]         SmallDateTime         NOT NULL,
        [MANAGER]      VarChar(100)          NOT NULL,
        [STATUS]       TinyInt               NOT NULL,
        [UPD_DATE]     DateTime              NOT NULL,
        [US_NAME]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientService] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientService(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientService(ID_SERVICE)_dbo.ServiceTable(ServiceID)] FOREIGN KEY  ([ID_SERVICE]) REFERENCES [dbo].[ServiceTable] ([ServiceID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ClientService(ID_CLIENT,ID_SERVICE,DATE,STATUS)] ON [dbo].[ClientService] ([ID_CLIENT] ASC, [ID_SERVICE] ASC, [DATE] ASC, [STATUS] ASC);
GO
