USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyPersonalPhone]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_PERSONAL]   UniqueIdentifier      NOT NULL,
        [ID_TYPE]       UniqueIdentifier          NULL,
        [PHONE]         NVarChar(256)         NOT NULL,
        [PHONE_S]       NVarChar(128)         NOT NULL,
        [NOTE]          NVarChar(Max)             NULL,
        [STATUS]        Int                   NOT NULL,
        [UPD_DATE]      DateTime                  NULL,
        [UPD_USER]      NVarChar(256)             NULL,
        CONSTRAINT [PK_CompanyPersonalPhone] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_CompanyPersonalPhone_CompanyPersonal] FOREIGN KEY  ([ID_PERSONAL]) REFERENCES [Client].[CompanyPersonal] ([ID]),
        CONSTRAINT [FK_CompanyPersonalPhone_PhoneType] FOREIGN KEY  ([ID_TYPE]) REFERENCES [Client].[PhoneType] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_ID_PERSONAL] ON [Client].[CompanyPersonalPhone] ([ID_PERSONAL] ASC) INCLUDE ([ID], [ID_TYPE], [PHONE], [PHONE_S], [NOTE]);
CREATE NONCLUSTERED INDEX [IX_PHONE] ON [Client].[CompanyPersonalPhone] ([PHONE_S] ASC) INCLUDE ([ID_PERSONAL], [STATUS]);
GO
