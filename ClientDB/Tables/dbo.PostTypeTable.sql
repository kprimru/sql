USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PostTypeTable]
(
        [PostTypeID]     Int           Identity(1,1)   NOT NULL,
        [PostTypeName]   VarChar(50)                   NOT NULL,
        CONSTRAINT [PK_dbo.PostTypeTable] PRIMARY KEY CLUSTERED ([PostTypeID])
);
GO
