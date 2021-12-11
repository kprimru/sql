USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Maintenance].[JobType]
(
        [Id]           SmallInt       Identity(1,1)   NOT NULL,
        [Name]         VarChar(250)                   NOT NULL,
        [ExpireTime]   Int                                NULL,
        CONSTRAINT [PK_Maintenance.JobType] PRIMARY KEY CLUSTERED ([Id])
);
GO
