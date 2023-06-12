USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrStatus]
(
        [DS_ID]      UniqueIdentifier      NOT NULL,
        [DS_NAME]    VarChar(64)           NOT NULL,
        [DS_REG]     TinyInt               NOT NULL,
        [DS_IMAGE]   varbinary             NOT NULL,
        [DS_INDEX]   TinyInt               NOT NULL,
        CONSTRAINT [PK_dbo.DistrStatus] PRIMARY KEY CLUSTERED ([DS_ID])
);
GO
