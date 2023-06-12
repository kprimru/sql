USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Control].[ControlGroup]
(
        [ID]      UniqueIdentifier      NOT NULL,
        [NAME]    NVarChar(256)         NOT NULL,
        [PSEDO]   NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Control.ControlGroup] PRIMARY KEY CLUSTERED ([ID])
);
GO
