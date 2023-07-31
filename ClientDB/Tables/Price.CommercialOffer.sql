USE [ClientDB]
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
        [ID_VENDOR]      UniqueIdentifier          NULL,
        [ID_CLIENT]      Int                       NULL,
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
        [OTHER]          Bit                   NOT NULL,
        CONSTRAINT [PK_Price.CommercialOffer] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Price.CommercialOffer(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_Price.CommercialOffer(ID_MASTER)_Price.CommercialOffer(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [Price].[CommercialOffer] ([ID]),
        CONSTRAINT [FK_Price.CommercialOffer(ID_VENDOR)_dbo.Vendor(ID)] FOREIGN KEY  ([ID_VENDOR]) REFERENCES [dbo].[Vendor] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Price.CommercialOffer(ID_CLIENT,STATUS)] ON [Price].[CommercialOffer] ([ID_CLIENT] ASC, [STATUS] ASC);
CREATE NONCLUSTERED INDEX [IX_Price.CommercialOffer(STATUS)+(NUM)] ON [Price].[CommercialOffer] ([STATUS] ASC) INCLUDE ([NUM]);
GO
