USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[TenderCity]
(
        [TCT_ID]          UniqueIdentifier      NOT NULL,
        [TCT_ID_TENDER]   UniqueIdentifier      NOT NULL,
        [TCT_ID_CITY]     UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.TenderCity] PRIMARY KEY CLUSTERED ([TCT_ID]),
        CONSTRAINT [FK_Purchase.TenderCity(TCT_ID_TENDER)_Purchase.Tender(TD_ID)] FOREIGN KEY  ([TCT_ID_TENDER]) REFERENCES [Purchase].[Tender] ([TD_ID]),
        CONSTRAINT [FK_Purchase.TenderCity(TCT_ID_CITY)_dbo.City(CT_ID)] FOREIGN KEY  ([TCT_ID_CITY]) REFERENCES [dbo].[City] ([CT_ID])
);
GO
