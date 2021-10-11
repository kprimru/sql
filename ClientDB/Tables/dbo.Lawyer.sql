USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lawyer]
(
        [LW_ID]      UniqueIdentifier      NOT NULL,
        [LW_SHORT]   VarChar(50)           NOT NULL,
        [LW_FULL]    VarChar(250)          NOT NULL,
        [LW_LOGIN]   VarChar(100)          NOT NULL,
        CONSTRAINT [PK_dbo.Lawyer] PRIMARY KEY CLUSTERED ([LW_ID])
);GO
