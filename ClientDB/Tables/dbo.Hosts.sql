USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Hosts]
(
        [HostID]      Int           Identity(1,1)   NOT NULL,
        [HostShort]   VarChar(50)                   NOT NULL,
        [HostReg]     VarChar(50)                   NOT NULL,
        [HostOrder]   Int                           NOT NULL,
        CONSTRAINT [PK_dbo.Hosts] PRIMARY KEY CLUSTERED ([HostID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.Hosts(HostReg)+(HostID)] ON [dbo].[Hosts] ([HostReg] ASC) INCLUDE ([HostID]);
GO
