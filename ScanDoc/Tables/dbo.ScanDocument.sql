USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScanDocument]
(
        [ID]               Int              Identity(1,1)   NOT NULL,
        [ID_MASTER]        Int                                  NULL,
        [ID_CATEGORY]      Int                              NOT NULL,
        [ID_DIRECTION]     Int                              NOT NULL,
        [ID_COMPANY]       Int                              NOT NULL,
        [ID_FORM]          Int                                  NULL,
        [NAME]             NVarChar(1024)                   NOT NULL,
        [DATE]             SmallDateTime                    NOT NULL,
        [DOC_NUM]          NVarChar(256)                        NULL,
        [DOC_DATE]         SmallDateTime                        NULL,
        [RES]              VarChar(256)                         NULL,
        [STATUS]           SmallInt                         NOT NULL,
        [UPD_DATE]         DateTime                         NOT NULL,
        [UPD_USER]         NVarChar(256)                    NOT NULL,
        [ExportDateTime]   DateTime                             NULL,
        CONSTRAINT [PK_ScanDocument] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_ScanDocument_Category] FOREIGN KEY  ([ID_CATEGORY]) REFERENCES [dbo].[Category] ([ID]),
        CONSTRAINT [FK_ScanDocument_Direction] FOREIGN KEY  ([ID_DIRECTION]) REFERENCES [dbo].[Direction] ([ID]),
        CONSTRAINT [FK_ScanDocument_Company] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [dbo].[Company] ([ID]),
        CONSTRAINT [FK_ScanDocument_Form] FOREIGN KEY  ([ID_FORM]) REFERENCES [dbo].[Form] ([ID]),
        CONSTRAINT [FK_ScanDocument_ScanDocument1] FOREIGN KEY  ([ID_MASTER]) REFERENCES [dbo].[ScanDocument] ([ID])
);
GO
