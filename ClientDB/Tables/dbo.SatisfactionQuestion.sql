USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SatisfactionQuestion]
(
        [SQ_ID]       UniqueIdentifier      NOT NULL,
        [SQ_TEXT]     VarChar(500)          NOT NULL,
        [SQ_SINGLE]   Bit                   NOT NULL,
        [SQ_BOLD]     Bit                   NOT NULL,
        [SQ_ORDER]    Int                   NOT NULL,
        [SQ_ACTIVE]   Bit                   NOT NULL,
        CONSTRAINT [PK_dbo.SatisfactionQuestion] PRIMARY KEY CLUSTERED ([SQ_ID])
);
GO
