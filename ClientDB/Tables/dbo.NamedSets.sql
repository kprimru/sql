USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NamedSets]
(
        [SetId]     UniqueIdentifier      NOT NULL,
        [RefName]   NVarChar(256)         NOT NULL,
        [SetName]   NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.NamedSets] PRIMARY KEY CLUSTERED ([SetId])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.NamedSets(RefName,SetName)] ON [dbo].[NamedSets] ([RefName] ASC, [SetName] ASC);
GO
