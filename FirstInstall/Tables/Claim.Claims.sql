USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[Claims]
(
        [CLM_ID]        UniqueIdentifier      NOT NULL,
        [CLM_DATE]      DateTime              NOT NULL,
        [CLM_ID_USER]   UniqueIdentifier      NOT NULL,
        [CLM_NUM]       Int                   NOT NULL,
        CONSTRAINT [PK_Claims] PRIMARY KEY CLUSTERED ([CLM_ID]),
        CONSTRAINT [FK_Claims_Users] FOREIGN KEY  ([CLM_ID_USER]) REFERENCES [Security].[Users] ([USMS_ID])
);GO
