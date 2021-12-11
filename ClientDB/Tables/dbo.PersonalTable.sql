USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersonalTable]
(
        [PersonalID]          Int            Identity(1,1)   NOT NULL,
        [DepartmentName]      VarChar(50)                    NOT NULL,
        [PersonalShortName]   VarChar(50)                    NOT NULL,
        [PersonalFullName]    VarChar(500)                   NOT NULL,
        CONSTRAINT [PK_dbo.PersonalTable] PRIMARY KEY CLUSTERED ([PersonalID])
);
GO
