USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[Action]
(
        [ID]               UniqueIdentifier      NOT NULL,
        [NAME]             NVarChar(256)         NOT NULL,
        [DELIVERY]         SmallInt              NOT NULL,
        [SUPPORT]          SmallInt                  NULL,
        [DELIVERY_FIXED]   Money                     NULL,
        CONSTRAINT [PK_Price.Action] PRIMARY KEY CLUSTERED ([ID])
);
GO
