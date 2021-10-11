USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Mailing].[Requests]
(
        [ID]              Int             Identity(1,1)   NOT NULL,
        [HostID]          SmallInt                        NOT NULL,
        [Distr]           Int                             NOT NULL,
        [Comp]            TinyInt                         NOT NULL,
        [OriginalEmail]   NVarChar(510)                   NOT NULL,
        [Email]           NVarChar(510)                       NULL,
        [UpdateDate]      DateTime                        NOT NULL,
        [SendDate]        DateTime                            NULL,
        [ConfirmDate]     DateTime                            NULL,
        CONSTRAINT [PK_Mailing.Requests] PRIMARY KEY CLUSTERED ([ID])
);GO
