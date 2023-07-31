USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[Tender]
(
        [TD_ID]            UniqueIdentifier      NOT NULL,
        [TD_ID_MASTER]     UniqueIdentifier          NULL,
        [TD_ID_CLIENT]     Int                   NOT NULL,
        [TD_NOTICE_NUM]    VarChar(20)           NOT NULL,
        [TD_NOTICE_DATE]   SmallDateTime         NOT NULL,
        [TD_ID_NAME]       UniqueIdentifier      NOT NULL,
        [TD_CANCEL_DATE]   SmallDateTime             NULL,
        [TD_NOTE]          NVarChar(Max)             NULL,
        [TD_STATUS]        TinyInt               NOT NULL,
        [TD_UPDATE]        DateTime              NOT NULL,
        [TD_UPDATE_USER]   VarChar(128)          NOT NULL,
        CONSTRAINT [PK_Purchase.Tender] PRIMARY KEY CLUSTERED ([TD_ID]),
        CONSTRAINT [FK_Purchase.Tender(TD_ID_MASTER)_Purchase.Tender(TD_ID)] FOREIGN KEY  ([TD_ID_MASTER]) REFERENCES [Purchase].[Tender] ([TD_ID]),
        CONSTRAINT [FK_Purchase.Tender(TD_ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([TD_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_Purchase.Tender(TD_ID_NAME)_Purchase.TenderName(TN_ID)] FOREIGN KEY  ([TD_ID_NAME]) REFERENCES [Purchase].[TenderName] ([TN_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Purchase.Tender(TD_ID_CLIENT,TD_STATUS)] ON [Purchase].[Tender] ([TD_ID_CLIENT] ASC, [TD_STATUS] ASC);
GO
