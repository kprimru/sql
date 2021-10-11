USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientMessage]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [ID_MASTER]      UniqueIdentifier          NULL,
        [ID_CLIENT]      Int                       NULL,
        [TP]             TinyInt               NOT NULL,
        [SENDER]         NVarChar(256)         NOT NULL,
        [DATE]           DateTime              NOT NULL,
        [NOTE]           NVarChar(Max)         NOT NULL,
        [RECEIVE_USER]   NVarChar(256)         NOT NULL,
        [RECEIVE_DATE]   DateTime                  NULL,
        [RECEIVE_HOST]   NVarChar(256)             NULL,
        [HARD_READ]      Bit                   NOT NULL,
        [DELAY_MIN]      Int                   NOT NULL,
        [REMIND_DATE]    DateTime              NOT NULL,
        [HIDE]           Bit                   NOT NULL,
        [STATUS]         TinyInt               NOT NULL,
        [UPD_DATE]       DateTime              NOT NULL,
        [UPD_USER]       NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientMessage] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientMessage(ID_MASTER)_dbo.ClientMessage(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [dbo].[ClientMessage] ([ID]),
        CONSTRAINT [FK_dbo.ClientMessage(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientMessage(ID_CLIENT,STATUS)+(SENDER,DATE,NOTE)] ON [dbo].[ClientMessage] ([ID_CLIENT] ASC, [STATUS] ASC) INCLUDE ([SENDER], [DATE], [NOTE]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientMessage(RECEIVE_USER,HIDE,STATUS)+(ID,ID_CLIENT,DATE,NOTE,UPD_DATE)] ON [dbo].[ClientMessage] ([RECEIVE_USER] ASC, [HIDE] ASC, [STATUS] ASC) INCLUDE ([ID], [ID_CLIENT], [DATE], [NOTE], [UPD_DATE]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientMessage(RECEIVE_USER,RECEIVE_DATE,STATUS,REMIND_DATE)] ON [dbo].[ClientMessage] ([RECEIVE_USER] ASC, [RECEIVE_DATE] ASC, [STATUS] ASC, [REMIND_DATE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientMessage(SENDER,DATE,STATUS)+(RECEIVE_USER,RECEIVE_DATE,NOTE,TP)] ON [dbo].[ClientMessage] ([SENDER] ASC, [DATE] ASC, [STATUS] ASC) INCLUDE ([RECEIVE_USER], [RECEIVE_DATE], [NOTE], [TP]);
GO
