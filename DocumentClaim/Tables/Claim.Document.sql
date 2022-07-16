USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[Document]
(
        [ID]              UniqueIdentifier      NOT NULL,
        [ID_MASTER]       UniqueIdentifier          NULL,
        [DATE]            DateTime              NOT NULL,
        [DATE_S]           AS ([Common].[DateOf]([DATE])) PERSISTED,
        [ID_AUTHOR]       UniqueIdentifier      NOT NULL,
        [ID_CLIENT]       NVarChar(256)             NULL,
        [CL_TYPE]         NVarChar(32)              NULL,
        [CL_NAME]         NVarChar(512)         NOT NULL,
        [ID_TYPE]         UniqueIdentifier      NOT NULL,
        [ID_VENDOR]       UniqueIdentifier      NOT NULL,
        [NOTE]            NVarChar(Max)         NOT NULL,
        [SALE_PERSONAL]   NVarChar(256)             NULL,
        [VERIFY_NEED]     Bit                       NULL,
        [VERIFY_USER]     UniqueIdentifier          NULL,
        [VERIFY_DATE]     DateTime                  NULL,
        [VERIFY_NOTE]     NVarChar(Max)             NULL,
        [STATUS]          TinyInt               NOT NULL,
        [UPD_DATE]        DateTime              NOT NULL,
        [UPD_USER]        NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Claim.Document] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Claim.Document(CL_NAME)] ON [Claim].[Document] ([CL_NAME] ASC);
CREATE NONCLUSTERED INDEX [IX_Claim.Document(DATE_S)] ON [Claim].[Document] ([DATE_S] ASC);
CREATE NONCLUSTERED INDEX [IX_Claim.Document(ID_AUTHOR)] ON [Claim].[Document] ([ID_AUTHOR] ASC);
GO
