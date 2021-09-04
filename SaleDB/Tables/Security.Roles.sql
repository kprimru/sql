USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[Roles]
(
        [ID]        UniqueIdentifier      NOT NULL,
        [MASTER]    UniqueIdentifier          NULL,
        [NAME]      NVarChar(256)             NULL,
        [CAPTION]   NVarChar(512)             NULL,
        [NOTE]      NVarChar(Max)             NULL,
        [LAST]      DateTime              NOT NULL,
        CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Roles_Roles] FOREIGN KEY  ([MASTER]) REFERENCES [Security].[Roles] ([ID])
);GO
