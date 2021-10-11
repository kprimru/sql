USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientErrorReason]
(
        [ID]         UniqueIdentifier      NOT NULL,
        [TP]         NVarChar(256)         NOT NULL,
        [NAME]       NVarChar(256)         NOT NULL,
        [ID_GROUP]   UniqueIdentifier          NULL,
        [RS_TYPE]    TinyInt               NOT NULL,
        [ORD]        Int                   NOT NULL,
        CONSTRAINT [PK_dbo.ClientErrorReason] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientErrorReason(ID_GROUP)_dbo.ClientErrorReason(ID)] FOREIGN KEY  ([ID_GROUP]) REFERENCES [dbo].[ClientErrorReason] ([ID])
);GO
