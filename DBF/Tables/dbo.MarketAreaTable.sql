USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MarketAreaTable]
(
        [MA_ID]           SmallInt       Identity(1,1)   NOT NULL,
        [MA_NAME]         VarChar(150)                   NOT NULL,
        [MA_SHORT_NAME]   VarChar(20)                    NOT NULL,
        [MA_ACTIVE]       Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.MarketAreaTable] PRIMARY KEY CLUSTERED ([MA_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_U_MA_SHORT] ON [dbo].[MarketAreaTable] ([MA_SHORT_NAME] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.MarketAreaTable()] ON [dbo].[MarketAreaTable] ([MA_NAME] ASC);
GO
