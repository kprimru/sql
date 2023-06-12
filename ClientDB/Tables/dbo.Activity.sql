USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Activity]
(
        [AC_ID]      UniqueIdentifier      NOT NULL,
        [AC_NAME]    VarChar(500)          NOT NULL,
        [AC_CODE]    VarChar(30)           NOT NULL,
        [AC_SHORT]   VarChar(100)              NULL,
        CONSTRAINT [PK_dbo.Activity] PRIMARY KEY CLUSTERED ([AC_ID])
);
GO
