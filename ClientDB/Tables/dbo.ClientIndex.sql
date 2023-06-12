USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientIndex]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_CLIENT]   Int                   NOT NULL,
        [DATA]        NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientIndex] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientIndex(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientIndex(ID_CLIENT)] ON [dbo].[ClientIndex] ([ID_CLIENT] ASC);
GO
