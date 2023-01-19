﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[DistrStore]
(
        [DS_ID]        UniqueIdentifier      NOT NULL,
        [DS_ID_HOST]   UniqueIdentifier      NOT NULL,
        [DS_NUM]       Int                   NOT NULL,
        [DS_COMP]      SmallInt              NOT NULL,
        [DS_LAST]      DateTime              NOT NULL,
        CONSTRAINT [PK_Distr.DistrStore] PRIMARY KEY CLUSTERED ([DS_ID]),
        CONSTRAINT [FK_Distr.DistrStore(DS_ID_HOST)_Distr.Hosts(HSTMS_ID)] FOREIGN KEY  ([DS_ID_HOST]) REFERENCES [Distr].[Hosts] ([HSTMS_ID])
);
GO
