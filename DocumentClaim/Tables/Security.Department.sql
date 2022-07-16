USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[Department]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [NAME]     NVarChar(256)         NOT NULL,
        [STATUS]   TinyInt               NOT NULL,
        [LAST]     DateTime              NOT NULL,
        CONSTRAINT [PK_Security.Department] PRIMARY KEY CLUSTERED ([ID])
);GO
