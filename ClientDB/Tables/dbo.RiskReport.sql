USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RiskReport]
(
        [Id]         Int        Identity(1,1)   NOT NULL,
        [DateTime]   DateTime                       NULL,
        CONSTRAINT [PK__RiskRepo__3214EC0746F00C52] PRIMARY KEY CLUSTERED ([Id])
);
GO
