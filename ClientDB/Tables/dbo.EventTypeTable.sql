USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventTypeTable]
(
        [EventTypeID]       Int           Identity(1,1)   NOT NULL,
        [EventTypeName]     VarChar(50)                   NOT NULL,
        [EventTypeReport]   Bit                           NOT NULL,
        [EventTypeHide]     Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.EventTypeTable] PRIMARY KEY CLUSTERED ([EventTypeID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.EventTypeTable(EventTypeName)] ON [dbo].[EventTypeTable] ([EventTypeName] ASC);
GO
