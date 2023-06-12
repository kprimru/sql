USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Cache].[Client?Names]
(
        [Id]      Int               NOT NULL,
        [Names]   VarChar(Max)          NULL,
        CONSTRAINT [PK_Cache.Client?Names] PRIMARY KEY CLUSTERED ([Id])
);
GO
