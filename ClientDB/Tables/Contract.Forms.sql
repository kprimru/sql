USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[Forms]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [NUM]         NVarChar(256)         NOT NULL,
        [NAME]        NVarChar(2048)        NOT NULL,
        [FILE_PATH]   NVarChar(2048)        NOT NULL,
        CONSTRAINT [PK_Contract.Forms] PRIMARY KEY CLUSTERED ([ID])
);GO
