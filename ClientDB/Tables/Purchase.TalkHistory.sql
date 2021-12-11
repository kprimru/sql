USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[TalkHistory]
(
        [TH_ID]          UniqueIdentifier      NOT NULL,
        [TH_ID_MASTER]   UniqueIdentifier          NULL,
        [TH_ID_CLIENT]   Int                   NOT NULL,
        [TH_DATE]        SmallDateTime         NOT NULL,
        [TH_WHO]         VarChar(150)          NOT NULL,
        [TH_PERSONAL]    VarChar(150)          NOT NULL,
        [TH_THEME]       VarChar(Max)          NOT NULL,
        [TH_STATUS]      TinyInt               NOT NULL,
        [TH_UPDATE]      DateTime              NOT NULL,
        [TH_USER]        NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Purchase.TalkHistory] PRIMARY KEY CLUSTERED ([TH_ID]),
        CONSTRAINT [FK_Purchase.TalkHistory(TH_ID_MASTER)_Purchase.TalkHistory(TH_ID)] FOREIGN KEY  ([TH_ID_MASTER]) REFERENCES [Purchase].[TalkHistory] ([TH_ID]),
        CONSTRAINT [FK_Purchase.TalkHistory(TH_ID_CLIENT)_Purchase.ClientTable(ClientID)] FOREIGN KEY  ([TH_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
