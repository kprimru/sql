USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[Contracts->Documents Flow Types]
(
        [Id]     TinyInt        Identity(1,1)   NOT NULL,
        [Name]   VarChar(100)                   NOT NULL,
        [Code]   VarChar(50)                    NOT NULL,
        CONSTRAINT [PK_Contract.Contracts->Documents Flow Types] PRIMARY KEY CLUSTERED ([Id])
);
GO
