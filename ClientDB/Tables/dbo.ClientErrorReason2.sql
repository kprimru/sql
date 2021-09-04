USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientErrorReason2]
(
        [ID]         UniqueIdentifier      NOT NULL,
        [TP]         NVarChar(256)         NOT NULL,
        [NAME]       NVarChar(256)         NOT NULL,
        [ID_GROUP]   UniqueIdentifier          NULL,
        [RS_TYPE]    TinyInt               NOT NULL,
        [ORD]        Int                   NOT NULL,
);GO
