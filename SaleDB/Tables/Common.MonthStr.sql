USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[MonthStr]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   VarChar(50)           NOT NULL,
        [ROD]    VarChar(50)           NOT NULL,
        [NUM]    Int                   NOT NULL,
        CONSTRAINT [PK_Common.MonthStr] PRIMARY KEY CLUSTERED ([ID])
);
GO
