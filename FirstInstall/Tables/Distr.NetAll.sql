USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[NetAll]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [NAME]        VarChar(100)          NOT NULL,
        [SHORT]       VarChar(10)           NOT NULL,
        [COEF]        decimal               NOT NULL,
        [VMI_COEF]    decimal               NOT NULL,
        [NET_COUNT]   SmallInt              NOT NULL,
        [TECH]        SmallInt              NOT NULL,
        [LAST]        DateTime              NOT NULL,
        CONSTRAINT [PK_NetAll] PRIMARY KEY CLUSTERED ([ID])
);GO
