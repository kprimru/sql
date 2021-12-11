USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Maintenance].[Version]
(
        [VERSION]   VarChar(50)        NOT NULL,
        [DATE]      SmallDateTime      NOT NULL,
        [INSTALL]   DateTime           NOT NULL,
        CONSTRAINT [PK_Maintenance.Version] PRIMARY KEY CLUSTERED ([VERSION])
);
GO
