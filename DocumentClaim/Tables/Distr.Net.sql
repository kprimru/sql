USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[Net]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [SHORT]       NVarChar(128)         NOT NULL,
        [NET_COUNT]   SmallInt              NOT NULL,
        [TECH]        SmallInt              NOT NULL,
        [COEF]        decimal               NOT NULL,
        [STATUS]      TinyInt               NOT NULL,
        [LAST]        DateTime              NOT NULL,
        CONSTRAINT [PK_Distr.Net] PRIMARY KEY CLUSTERED ([ID])
);GO
