USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InfoPanelUser]
(
        [ID]         UniqueIdentifier      NOT NULL,
        [ID_PANEL]   UniqueIdentifier      NOT NULL,
        [USR_NAME]   NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.InfoPanelUser] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.InfoPanelUser(ID_PANEL)_dbo.InfoPanel(ID)] FOREIGN KEY  ([ID_PANEL]) REFERENCES [dbo].[InfoPanel] ([ID])
);
GO
