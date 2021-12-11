USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientDisconnect]
(
        [CD_ID]          UniqueIdentifier      NOT NULL,
        [CD_ID_CLIENT]   Int                   NOT NULL,
        [CD_TYPE]        TinyInt               NOT NULL,
        [CD_DATE]        SmallDateTime         NOT NULL,
        [CD_ID_REASON]   UniqueIdentifier          NULL,
        [CD_ID_STATUS]   Int                   NOT NULL,
        [CD_NOTE]        VarChar(Max)          NOT NULL,
        [CD_DATETIME]    DateTime              NOT NULL,
        [CD_USER]        NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientDisconnect] PRIMARY KEY CLUSTERED ([CD_ID]),
        CONSTRAINT [FK_dbo.ClientDisconnect(CD_ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([CD_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientDisconnect(CD_ID_REASON)_dbo.DisconnectReason(DR_ID)] FOREIGN KEY  ([CD_ID_REASON]) REFERENCES [dbo].[DisconnectReason] ([DR_ID])
);
GO
