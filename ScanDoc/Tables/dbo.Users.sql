USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users]
(
        [ID]      Int             Identity(1,1)   NOT NULL,
        [LGN]     NVarChar(256)                   NOT NULL,
        [SHORT]   NVarChar(256)                   NOT NULL,
        [LAST]    DateTime                        NOT NULL,
        CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([ID])
);
GO
