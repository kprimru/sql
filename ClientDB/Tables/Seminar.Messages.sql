USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seminar].[Messages]
(
        [ID]      UniqueIdentifier      NOT NULL,
        [PSEDO]   NVarChar(512)         NOT NULL,
        [TXT]     NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_Seminar.Messages] PRIMARY KEY CLUSTERED ([ID])
);
GO
