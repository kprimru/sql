USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DutyTable]
(
        [DutyID]       Int           Identity(1,1)   NOT NULL,
        [DutyName]     VarChar(50)                   NOT NULL,
        [DutyLogin]    VarChar(50)                   NOT NULL,
        [DutyActive]   Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.DutyTable] PRIMARY KEY CLUSTERED ([DutyID])
);GO
