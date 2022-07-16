USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[System]
(
        [ID]        UniqueIdentifier      NOT NULL,
        [SHORT]     NVarChar(256)         NOT NULL,
        [REG]       NVarChar(128)         NOT NULL,
        [ID_HOST]   UniqueIdentifier      NOT NULL,
        [ORD]       Int                   NOT NULL,
        [STATUS]    TinyInt               NOT NULL,
        [LAST]      DateTime              NOT NULL,
        CONSTRAINT [PK_Distr.System] PRIMARY KEY CLUSTERED ([ID])
);GO
