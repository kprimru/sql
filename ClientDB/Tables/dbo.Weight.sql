USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Weight]
(
        [Date]       SmallDateTime      NOT NULL,
        [Sys]        VarChar(50)        NOT NULL,
        [SysType]    VarChar(50)        NOT NULL,
        [NetCount]   SmallInt           NOT NULL,
        [NetTech]    SmallInt           NOT NULL,
        [NetOdon]    SmallInt           NOT NULL,
        [NetOdoff]   SmallInt           NOT NULL,
        [Weight]     decimal            NOT NULL,
        CONSTRAINT [PK_dbo.Weight] PRIMARY KEY CLUSTERED ([Date],[Sys],[SysType],[NetCount],[NetTech],[NetOdon],[NetOdoff])
);
GO
