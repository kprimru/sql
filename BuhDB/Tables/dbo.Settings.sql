USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Settings]
(
        [Name]    VarChar(100)      NOT NULL,
        [Value]   sql_variant           NULL,
        CONSTRAINT [PK_dbo.Settings] PRIMARY KEY CLUSTERED ([Name])
);
GO
