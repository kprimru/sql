USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InfoPanel]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_MASTER]   UniqueIdentifier          NULL,
        [TEXT]        NVarChar(1024)        NOT NULL,
        [DETAIL]      NVarChar(Max)         NOT NULL,
        [STATUS]      TinyInt               NOT NULL,
        [UPD_DATE]    DateTime              NOT NULL,
        [UPD_USER]    NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.InfoPanel] PRIMARY KEY CLUSTERED ([ID])
);GO
