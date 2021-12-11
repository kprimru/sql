USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Din].[NetType:Synonyms]
(
        [Net_Id]    Int               NOT NULL,
        [NT_NAME]   VarChar(100)      NOT NULL,
        [NT_NOTE]   VarChar(100)      NOT NULL,
        CONSTRAINT [PK_Din.NetType:Synonyms] PRIMARY KEY CLUSTERED ([Net_Id],[NT_NAME],[NT_NOTE])
);
GO
