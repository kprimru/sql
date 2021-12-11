USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BLACK_LIST_PARAMS]
(
        [ID]           Int             Identity(1,1)   NOT NULL,
        [PARAMNAME]    VarChar(50)                     NOT NULL,
        [PARAMVALUE]   VarChar(2048)                       NULL,
        CONSTRAINT [PK_dbo.BLACK_LIST_PARAMS] PRIMARY KEY CLUSTERED ([PARAMNAME])
);
GO
