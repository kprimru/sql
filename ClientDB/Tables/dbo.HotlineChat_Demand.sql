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
        CONSTRAINT [PK_HotlineChat=Demand:Item] PRIMARY KEY CLUSTERED ([HotlineChat_Id],[Demand_Id]),
        CONSTRAINT [FK_HotlineChat=Demand:Item_Demand->Type1] FOREIGN KEY  ([Demand_Id]) REFERENCES [dbo].[Demand->Type] ([Id]),
        CONSTRAINT [FK_HotlineChat=Demand:Item_HotlineChat] FOREIGN KEY  ([HotlineChat_Id]) REFERENCES [dbo].[HotlineChat] ([ID])
);
GO
