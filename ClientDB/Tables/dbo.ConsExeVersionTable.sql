USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConsExeVersionTable]
(
        [ConsExeVersionID]       Int             Identity(1,1)   NOT NULL,
        [ConsExeVersionName]     VarChar(50)                     NOT NULL,
        [ConsExeVersionActive]   Bit                             NOT NULL,
        [ConsExeVersionBegin]    SmallDateTime                       NULL,
        [ConsExeVersionEnd]      SmallDateTime                       NULL,
        CONSTRAINT [PK_dbo.ConsExeVersionTable] PRIMARY KEY CLUSTERED ([ConsExeVersionID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ConsExeVersionTable(ConsExeVersionName)] ON [dbo].[ConsExeVersionTable] ([ConsExeVersionName] ASC);
GO
