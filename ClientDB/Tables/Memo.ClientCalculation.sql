USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Memo].[ClientCalculation]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_CLIENT]   Int                   NOT NULL,
        [DATE]        SmallDateTime         NOT NULL,
        [AUTHOR]      NVarChar(256)         NOT NULL,
        [NOTE]        NVarChar(Max)         NOT NULL,
        [SYSTEMS]     NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_Memo.ClientCalculation] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Memo.ClientCalculation(ID_CLIENT)_Memo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Memo.ClientCalculation(ID_CLIENT)] ON [Memo].[ClientCalculation] ([ID_CLIENT] ASC);
GO
