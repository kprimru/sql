USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IP].[Lists]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [ID_HOST]        SmallInt              NOT NULL,
        [DISTR]          Int                   NOT NULL,
        [COMP]           TinyInt               NOT NULL,
        [TP]             TinyInt               NOT NULL,
        [SET_DATE]       DateTime              NOT NULL,
        [SET_USER]       NVarChar(256)         NOT NULL,
        [SET_REASON]     NVarChar(Max)         NOT NULL,
        [UNSET_DATE]     DateTime                  NULL,
        [UNSET_USER]     NVarChar(256)             NULL,
        [UNSET_REASON]   NVarChar(256)             NULL,
        [LAST_UPDATE]    DateTime              NOT NULL,
        CONSTRAINT [PK_IP.Lists] PRIMARY KEY CLUSTERED ([ID])
);
GO
