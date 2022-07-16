USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Document].[Document]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_TYPE]     UniqueIdentifier      NOT NULL,
        [DATE]        DateTime              NOT NULL,
        [DATE_S]       AS ([Common].[DateOf]([DATE])) ,
        [ID_CLIENT]   NVarChar(256)             NULL,
        [CL_TYPE]     NVarChar(32)          NOT NULL,
        [CL_NAME]     NVarChar(512)         NOT NULL,
        [NUM]         NVarChar(512)             NULL,
        [NOTE]        NVarChar(Max)             NULL,
        [PERSONAL]    NVarChar(512)             NULL,
        [STATUS]      TinyInt               NOT NULL,
        [UPD_DATE]    DateTime              NOT NULL,
        [UPD_USER]    NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Document.Document] PRIMARY KEY CLUSTERED ([ID])
);GO
