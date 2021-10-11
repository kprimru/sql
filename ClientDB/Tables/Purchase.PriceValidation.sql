USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[PriceValidation]
(
        [PV_ID]      UniqueIdentifier      NOT NULL,
        [PV_NAME]    VarChar(4000)         NOT NULL,
        [PV_SHORT]   VarChar(200)          NOT NULL,
        CONSTRAINT [PK_Purchase.PriceValidation] PRIMARY KEY CLUSTERED ([PV_ID])
);GO
