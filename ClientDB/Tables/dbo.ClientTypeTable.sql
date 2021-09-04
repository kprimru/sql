USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientTypeTable]
(
        [ClientTypeID]         TinyInt    Identity(1,1)   NOT NULL,
        [ClientTypeName]       char(1)                    NOT NULL,
        [ClientTypeDailyDay]   TinyInt                    NOT NULL,
        [ClientTypeDay]        TinyInt                    NOT NULL,
        [ClientTypePapper]     SmallInt                   NOT NULL,
        CONSTRAINT [PK_dbo.ClientTypeTable] PRIMARY KEY CLUSTERED ([ClientTypeID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ClientTypeTable(ClientTypeName)] ON [dbo].[ClientTypeTable] ([ClientTypeName] ASC);
GO
