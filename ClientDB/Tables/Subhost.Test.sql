USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[Test]
(
        [ID]              UniqueIdentifier      NOT NULL,
        [NAME]            NVarChar(256)         NOT NULL,
        [QST_CNT]         SmallInt              NOT NULL,
        [QST_SUCCESS]     SmallInt              NOT NULL,
        [INSTANT_CHECK]   Bit                   NOT NULL,
        CONSTRAINT [PK_Subhost.Test] PRIMARY KEY CLUSTERED ([ID])
);
GO
