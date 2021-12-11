USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tender].[Call]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_MASTER]   UniqueIdentifier          NULL,
        [ID_TENDER]   UniqueIdentifier      NOT NULL,
        [DATE]        SmallDateTime         NOT NULL,
        [SUBJECT]     NVarChar(256)         NOT NULL,
        [SURNAME]     NVarChar(256)         NOT NULL,
        [NAME]        NVarChar(256)         NOT NULL,
        [PATRON]      NVarChar(256)         NOT NULL,
        [PHONE]       NVarChar(256)         NOT NULL,
        [NOTE]        NVarChar(Max)         NOT NULL,
        [STATUS]      TinyInt               NOT NULL,
        [UPD_DATE]    DateTime              NOT NULL,
        [UPD_USER]    NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Tender.Call] PRIMARY KEY CLUSTERED ([ID])
);
GO
