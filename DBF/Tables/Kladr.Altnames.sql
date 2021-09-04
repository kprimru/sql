USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Kladr].[Altnames]
(
        [KA_ID]        UniqueIdentifier      NOT NULL,
        [KA_OLDCODE]   NVarChar(128)             NULL,
        [KA_NEWCODE]   NVarChar(128)             NULL,
        [KA_LEVEL]     NVarChar(16)              NULL,
        CONSTRAINT [PK_Kladr.Altnames] PRIMARY KEY CLUSTERED ([KA_ID])
);GO
