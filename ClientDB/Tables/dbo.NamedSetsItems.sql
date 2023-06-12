USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NamedSetsItems]
(
        [ItemId]    UniqueIdentifier      NOT NULL,
        [SetId]     UniqueIdentifier      NOT NULL,
        [SetItem]   sql_variant           NOT NULL,
        CONSTRAINT [PK_dbo.NamedSetsItems] PRIMARY KEY NONCLUSTERED ([ItemId]),
        CONSTRAINT [FK_dbo.NamedSetsItems(SetId)_dbo.NamedSets(SetId)] FOREIGN KEY  ([SetId]) REFERENCES [dbo].[NamedSets] ([SetId])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.NamedSetsItems(SetId)] ON [dbo].[NamedSetsItems] ([SetId] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.NamedSetsItems(SetItem,SetId)] ON [dbo].[NamedSetsItems] ([SetItem] ASC, [SetId] ASC);
GO
