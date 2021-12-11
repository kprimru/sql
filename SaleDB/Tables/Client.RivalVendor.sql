USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[RivalVendor]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(512)         NOT NULL,
        [LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Client.RivalVendor] PRIMARY KEY CLUSTERED ([ID])
);GO
