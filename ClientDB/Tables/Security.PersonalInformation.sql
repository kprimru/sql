USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[PersonalInformation]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [USER_LOGIN]     NVarChar(256)         NOT NULL,
        [OFFER_STRING]   NVarChar(2048)        NOT NULL,
        CONSTRAINT [PK_Security.PersonalInformation] PRIMARY KEY CLUSTERED ([ID])
);
GO
