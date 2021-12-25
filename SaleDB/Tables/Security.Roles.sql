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
        CONSTRAINT [PK_Security.Roles] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Security.Roles(MASTER)_Security.Roles(ID)] FOREIGN KEY  ([MASTER]) REFERENCES [Security].[Roles] ([ID])
);GO
