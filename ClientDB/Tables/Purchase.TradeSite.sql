USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[TradeSite]
(
        [TS_ID]      UniqueIdentifier      NOT NULL,
        [TS_NAME]    VarChar(4000)         NOT NULL,
        [TS_URL]     VarChar(250)              NULL,
        [TS_SHORT]   VarChar(200)              NULL,
        CONSTRAINT [PK_Purchase.TradeSite] PRIMARY KEY CLUSTERED ([TS_ID])
);
GO
