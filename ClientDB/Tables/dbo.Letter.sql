USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Letter]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(512)         NOT NULL,
        [GRP]    NVarChar(512)         NOT NULL,
        [DATA]   NVarChar(Max)         NOT NULL,
        [TXT]    NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_dbo.Letter] PRIMARY KEY CLUSTERED ([ID])
);
GO
