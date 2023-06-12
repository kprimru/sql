USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScanPages]
(
        [ID]            Int             Identity(1,1)   NOT NULL,
        [ID_DOCUMENT]   Int                             NOT NULL,
        [NUM]           SmallInt                        NOT NULL,
        [NAME]          NVarChar(256)                   NOT NULL,
        [EXT]           NVarChar(32)                    NOT NULL,
        [DATA]          varbinary                       NOT NULL,
        CONSTRAINT [PK_ScanPages] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_ScanPages_ScanDocument] FOREIGN KEY  ([ID_DOCUMENT]) REFERENCES [dbo].[ScanDocument] ([ID])
);
GO
