USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Category]
(
        [ID]          Int             Identity(1,1)   NOT NULL,
        [ID_MASTER]   Int                                 NULL,
        [NAME]        NVarChar(512)                   NOT NULL,
        [LAST]        DateTime                        NOT NULL,
        CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Category_Category] FOREIGN KEY  ([ID_MASTER]) REFERENCES [dbo].[Category] ([ID])
);
GO
