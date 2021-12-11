USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KGSDistrList]
(
        [KDL_ID]     Int           Identity(1,1)   NOT NULL,
        [KDL_NAME]   VarChar(50)                   NOT NULL,
        [KDL_LAST]   DateTime                      NOT NULL,
        CONSTRAINT [PK_dbo.KGSDistrList] PRIMARY KEY CLUSTERED ([KDL_ID])
);
GO
