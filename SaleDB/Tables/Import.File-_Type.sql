USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Import].[File->Type]
(
        [Id]     SmallInt       Identity(1,1)   NOT NULL,
        [Code]   VarChar(128)                   NOT NULL,
        [Name]   VarChar(128)                   NOT NULL,
        CONSTRAINT [PK__File->Ty__3214EC071166ED79] PRIMARY KEY CLUSTERED ([Id])
);
GO
