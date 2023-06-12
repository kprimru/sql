USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CallDirection]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(256)         NOT NULL,
        [DEF]    Bit                   NOT NULL,
        CONSTRAINT [PK_dbo.CallDirection] PRIMARY KEY CLUSTERED ([ID])
);
GO
