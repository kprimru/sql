USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TO:Locks]
(
        [To_Id]            Int                NOT NULL,
        [Row:Index]        SmallInt           NOT NULL,
        [DateFrom]         SmallDateTime      NOT NULL,
        [DateTo]           SmallDateTime          NULL,
        [ExpireDate]       SmallDateTime      NOT NULL,
        [StartUserName]    NVarChar(256)      NOT NULL,
        [StartDateTime]    DateTime           NOT NULL,
        [FinishUserName]   NVarChar(256)          NULL,
        [FinishDateTime]   DateTime               NULL,
        CONSTRAINT [PK_dbo.TO:Locks] PRIMARY KEY CLUSTERED ([To_Id],[Row:Index])
);GO
