USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[CommercialOffer]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [ID_MASTER]      UniqueIdentifier          NULL,
        [ID_TEMPLATE]    UniqueIdentifier          NULL,
        [ID_CLIENT]      UniqueIdentifier          NULL,
        [FULL_NAME]      NVarChar(2048)            NULL,
        [ADDRESS]        NVarChar(2048)            NULL,
        [DIRECTOR]       NVarChar(512)             NULL,
        [PER_SURNAME]    NVarChar(512)             NULL,
        [PER_NAME]       NVarChar(512)             NULL,
        [PER_PATRON]     NVarChar(512)             NULL,
        [DIRECTOR_POS]   NVarChar(512)             NULL,
        [DATE]           SmallDateTime         NOT NULL,
        [NUM]            Int                   NOT NULL,
        [NOTE]           NVarChar(Max)         NOT NULL,
        [DISCOUNT]       decimal                   NULL,
        [INFLATION]      decimal                   NULL,
        [STATUS]         TinyInt               NOT NULL,
        [CREATE_DATE]    DateTime              NOT NULL,
        [CREATE_USER]    NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_CommercialOffer] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_CommercialOffer_CommercialOffer] FOREIGN KEY  ([ID_MASTER]) REFERENCES [Price].[CommercialOffer] ([ID])
);GO
