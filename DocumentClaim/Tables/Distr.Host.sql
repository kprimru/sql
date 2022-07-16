USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[Host]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [SHORT]    NVarChar(256)         NOT NULL,
        [REG]      NVarChar(128)         NOT NULL,
        [ORD]      SmallInt              NOT NULL,
        [STATUS]   TinyInt               NOT NULL,
        [LAST]     DateTime              NOT NULL,
        CONSTRAINT [PK_Distr.Host] PRIMARY KEY CLUSTERED ([ID])
);GO
