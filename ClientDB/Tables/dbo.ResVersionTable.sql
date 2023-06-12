USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResVersionTable]
(
        [ResVersionID]       Int             Identity(1,1)   NOT NULL,
        [ResVersionNumber]   VarChar(50)                     NOT NULL,
        [ResVersionShort]    VarChar(50)                         NULL,
        [IsLatest]           Bit                             NOT NULL,
        [ResVersionBegin]    SmallDateTime                       NULL,
        [ResVersionEnd]      SmallDateTime                       NULL,
        CONSTRAINT [PK_dbo.ResVersionTable] PRIMARY KEY CLUSTERED ([ResVersionID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ResVersionTable(ResVersionNumber)] ON [dbo].[ResVersionTable] ([ResVersionNumber] ASC);
GO
