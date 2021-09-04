USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Personal].[OfficePersonal]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [MANAGER]        UniqueIdentifier          NULL,
        [SURNAME]        NVarChar(512)         NOT NULL,
        [NAME]           NVarChar(512)         NOT NULL,
        [PATRON]         NVarChar(512)         NOT NULL,
        [SHORT]          NVarChar(256)         NOT NULL,
        [LOGIN]          NVarChar(256)             NULL,
        [PASS]           NVarChar(256)             NULL,
        [START_DATE]     DateTime                  NULL,
        [END_DATE]       DateTime                  NULL,
        [LAST]           DateTime              NOT NULL,
        [OLD_ID]         UniqueIdentifier          NULL,
        [PHONE]          NVarChar(256)             NULL,
        [PHONE_OFFICE]   NVarChar(256)             NULL,
        CONSTRAINT [PK_OfficePersonal] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_OfficePersonal_OfficePersonal] FOREIGN KEY  ([MANAGER]) REFERENCES [Personal].[OfficePersonal] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_LAST] ON [Personal].[OfficePersonal] ([LAST] ASC);
CREATE NONCLUSTERED INDEX [IX_MANAGER] ON [Personal].[OfficePersonal] ([MANAGER] ASC) INCLUDE ([ID]);
GO
