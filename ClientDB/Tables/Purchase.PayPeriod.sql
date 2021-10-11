USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[PayPeriod]
(
        [PP_ID]      UniqueIdentifier      NOT NULL,
        [PP_NAME]    VarChar(500)          NOT NULL,
        [PP_SHORT]   VarChar(100)          NOT NULL,
        CONSTRAINT [PK_Purchase.PayPeriod] PRIMARY KEY CLUSTERED ([PP_ID])
);GO
