USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[DocumentStatus]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_DOCUMENT]   UniqueIdentifier      NOT NULL,
        [DATE]          DateTime              NOT NULL,
        [STATUS]        TinyInt               NOT NULL,
        [ID_AUTHOR]     UniqueIdentifier      NOT NULL,
        [NOTE]          NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_Claim.DocumentStatus] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Claim.DocumentStatus(ID_DOCUMENT,DATE,STATUS)] ON [Claim].[DocumentStatus] ([ID_DOCUMENT] ASC, [DATE] ASC, [STATUS] ASC);
GO
