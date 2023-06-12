USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[UserType]
(
        [UT_ID]     Int             Identity(1,1)   NOT NULL,
        [UT_NAME]   NVarChar(512)                   NOT NULL,
        [UT_ROLE]   NVarChar(512)                   NOT NULL,
        [UT_NOTE]   NVarChar(Max)                       NULL,
        CONSTRAINT [PK_Security.UserType] PRIMARY KEY CLUSTERED ([UT_ID])
);
GO
