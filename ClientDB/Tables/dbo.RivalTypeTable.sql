USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RivalTypeTable]
(
        [RivalTypeID]     Int           Identity(1,1)   NOT NULL,
        [RivalTypeName]   VarChar(50)                   NOT NULL,
        CONSTRAINT [PK_dbo.RivalTypeTable] PRIMARY KEY CLUSTERED ([RivalTypeID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.RivalTypeTable(RivalTypeName)] ON [dbo].[RivalTypeTable] ([RivalTypeName] ASC);
GO
