USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[CoveringLetter]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_CONTRACT]   UniqueIdentifier      NOT NULL,
        [DATE]          SmallDateTime         NOT NULL,
        [NOTE]          NVarChar(2048)        NOT NULL,
        CONSTRAINT [PK_Contract.CoveringLetter] PRIMARY KEY CLUSTERED ([ID])
);
GO
