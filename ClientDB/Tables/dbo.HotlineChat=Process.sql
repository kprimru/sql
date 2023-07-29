USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HotlineChat=Process]
(
        [Hotline_Id]         UniqueIdentifier      NOT NULL,
        [Date]               SmallDateTime         NOT NULL,
        [UpdUser]            NVarChar(256)         NOT NULL,
        [NotificationDate]   DateTime                  NULL,
        CONSTRAINT [PK_HotlineChat=Process] PRIMARY KEY CLUSTERED ([Hotline_Id]),
        CONSTRAINT [FK_HotlineChat=Demand_HotlineChat] FOREIGN KEY  ([Hotline_Id]) REFERENCES [dbo].[HotlineChat] ([ID])
);
GO
