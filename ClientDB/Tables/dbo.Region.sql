USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Region]
(
        [RG_ID]        UniqueIdentifier      NOT NULL,
        [RG_NAME]      VarChar(100)          NOT NULL,
        [RG_PREFIX]    VarChar(20)           NOT NULL,
        [RG_SUFFIX]    VarChar(20)           NOT NULL,
        [RG_NUM]       TinyInt                   NULL,
        [RG_DISPLAY]   Bit                   NOT NULL,
        CONSTRAINT [PK_dbo.Region] PRIMARY KEY CLUSTERED ([RG_ID])
);
GO
