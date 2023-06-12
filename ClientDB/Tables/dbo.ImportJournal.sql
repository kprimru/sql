USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportJournal]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [TYPE]     NVarChar(128)         NOT NULL,
        [DATE]     DateTime              NOT NULL,
        [RECORD]   bigint                NOT NULL,
        [TOTAL]    bigint                NOT NULL,
        CONSTRAINT [PK_dbo.ImportJournal] PRIMARY KEY CLUSTERED ([ID])
);
GO
