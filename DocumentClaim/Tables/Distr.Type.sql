USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[Type]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [SHORT]    NVarChar(128)         NOT NULL,
        [STATUS]   TinyInt               NOT NULL,
        [LAST]     DateTime              NOT NULL,
        CONSTRAINT [PK_Distr.Type] PRIMARY KEY CLUSTERED ([ID])
);GO
