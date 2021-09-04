USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OwnershipTable]
(
        [OwnershipID]     Int            Identity(1,1)   NOT NULL,
        [OwnershipName]   VarChar(100)                   NOT NULL,
        CONSTRAINT [PK_dbo.OwnershipTable] PRIMARY KEY CLUSTERED ([OwnershipID])
);GO
