USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seminar].[Status]
(
        [ID]      UniqueIdentifier      NOT NULL,
        [NAME]    NVarChar(512)         NOT NULL,
        [COLOR]   Int                   NOT NULL,
        [INDX]    SmallInt              NOT NULL,
        CONSTRAINT [PK_Seminar.Status] PRIMARY KEY CLUSTERED ([ID])
);
GO
