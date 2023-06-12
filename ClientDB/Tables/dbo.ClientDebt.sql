USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientDebt]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_CLIENT]   Int                   NOT NULL,
        [ID_DEBT]     UniqueIdentifier      NOT NULL,
        [START]       UniqueIdentifier      NOT NULL,
        [FINISH]      UniqueIdentifier          NULL,
        [NOTE]        NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientDebt] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientDebt(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientDebt(ID_DEBT)_dbo.DebtType(ID)] FOREIGN KEY  ([ID_DEBT]) REFERENCES [dbo].[DebtType] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDebt(ID_CLIENT)] ON [dbo].[ClientDebt] ([ID_CLIENT] ASC);
GO
