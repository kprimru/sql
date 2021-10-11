USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Din].[SystemType:Synonyms]
(
        [Type_Id]    Int               NOT NULL,
        [SST_NAME]   VarChar(100)      NOT NULL,
        [SST_NOTE]   VarChar(100)      NOT NULL,
        CONSTRAINT [PK_Din.SystemType:Synonyms] PRIMARY KEY CLUSTERED ([Type_Id],[SST_NAME],[SST_NOTE])
);GO
