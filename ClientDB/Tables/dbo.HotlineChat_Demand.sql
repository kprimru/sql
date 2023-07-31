USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HotlineChat:Demand]
(
        [HotlineChat_Id]   UniqueIdentifier      NOT NULL,
        [Demand_Id]        SmallInt              NOT NULL,
        CONSTRAINT [PK_dbo.HotlineChat:Demand] PRIMARY KEY CLUSTERED ([HotlineChat_Id],[Demand_Id]),
        CONSTRAINT [FK_dbo.HotlineChat:Demand(Demand_Id)_dbo.Demand->Type(Id)] FOREIGN KEY  ([Demand_Id]) REFERENCES [dbo].[Demand->Type] ([Id]),
        CONSTRAINT [FK_dbo.HotlineChat:Demand(HotlineChat_Id)_dbo.HotlineChat(ID)] FOREIGN KEY  ([HotlineChat_Id]) REFERENCES [dbo].[HotlineChat] ([ID])
);
GO
