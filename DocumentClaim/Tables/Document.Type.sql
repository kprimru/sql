USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Document].[Type]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [NAME]     NVarChar(512)         NOT NULL,
        [STATUS]   TinyInt               NOT NULL,
        [LAST]     DateTime              NOT NULL,
        CONSTRAINT [PK_Document.Type] PRIMARY KEY CLUSTERED ([ID])
);
GO
