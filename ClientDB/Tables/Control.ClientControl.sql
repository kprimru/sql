USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Control].[ClientControl]
(
        [ID]              UniqueIdentifier      NOT NULL,
        [ID_CLIENT]       Int                   NOT NULL,
        [DATE]            DateTime              NOT NULL,
        [AUTHOR]          NVarChar(256)         NOT NULL,
        [REMOVE_DATE]     DateTime                  NULL,
        [REMOVE_USER]     NVarChar(256)             NULL,
        [NOTE]            NVarChar(Max)         NOT NULL,
        [NOTIFY]          SmallDateTime             NULL,
        [ID_GROUP]        UniqueIdentifier          NULL,
        [RECEIVER]        NVarChar(256)             NULL,
        [REMOVE_GROUP]    Bit                   NOT NULL,
        [REMOVE_AUTHOR]   Bit                   NOT NULL,
        [REMOVE_NOTE]     NVarChar(Max)             NULL,
        CONSTRAINT [PK_Control.ClientControl] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Control.ClientControl(ID_CLIENT)_Control.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_Control.ClientControl(ID_GROUP)_Control.ControlGroup(ID)] FOREIGN KEY  ([ID_GROUP]) REFERENCES [Control].[ControlGroup] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Control.ClientControl(ID_CLIENT,REMOVE_DATE,NOTIFY)+(ID_GROUP,RECEIVER)] ON [Control].[ClientControl] ([ID_CLIENT] ASC, [REMOVE_DATE] ASC, [NOTIFY] ASC) INCLUDE ([ID_GROUP], [RECEIVER]);
CREATE NONCLUSTERED INDEX [IX_Control.ClientControl(REMOVE_DATE,NOTIFY)] ON [Control].[ClientControl] ([REMOVE_DATE] ASC, [NOTIFY] ASC);
GO
