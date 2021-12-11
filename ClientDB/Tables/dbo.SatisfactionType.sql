USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SatisfactionType]
(
        [STT_ID]       UniqueIdentifier      NOT NULL,
        [STT_NAME]     VarChar(50)           NOT NULL,
        [STT_RESULT]   Bit                   NOT NULL,
        CONSTRAINT [PK_dbo.SatisfactionType] PRIMARY KEY CLUSTERED ([STT_ID])
);
GO
