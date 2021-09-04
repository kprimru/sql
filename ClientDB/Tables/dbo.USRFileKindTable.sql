USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[USRFileKindTable]
(
        [USRFileKindID]          TinyInt        Identity(1,1)   NOT NULL,
        [USRFileKindName]        VarChar(20)                    NOT NULL,
        [USRFileKindShortName]   VarChar(50)                    NOT NULL,
        [USRFileKindShort]       VarChar(100)                       NULL,
        CONSTRAINT [PK_dbo.USRFileKindTable] PRIMARY KEY CLUSTERED ([USRFileKindID])
);GO
