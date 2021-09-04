USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Month]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   VarChar(50)           NOT NULL,
        [ROD]    VarChar(50)           NOT NULL,
        [NUM]    Int                   NOT NULL,
        CONSTRAINT [PK_dbo.Month] PRIMARY KEY CLUSTERED ([ID])
);GO
