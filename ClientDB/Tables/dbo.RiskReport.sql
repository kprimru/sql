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
        CONSTRAINT [PK_dbo.RiskReport] PRIMARY KEY CLUSTERED ([Id])
);
GO
