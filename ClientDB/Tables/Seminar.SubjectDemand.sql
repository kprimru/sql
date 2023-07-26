USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seminar].[SubjectDemand]
(
        [Subject_Id]   UniqueIdentifier      NOT NULL,
        [Demand_Id]    SmallInt              NOT NULL,
        CONSTRAINT [PK__SubjectD__4B8AB8F4D6D037A9] PRIMARY KEY CLUSTERED ([Subject_Id],[Demand_Id]),
        CONSTRAINT [FK_Subject] FOREIGN KEY  ([Subject_Id]) REFERENCES [Seminar].[Subject] ([ID]),
        CONSTRAINT [FK_Demand] FOREIGN KEY  ([Demand_Id]) REFERENCES [dbo].[Demand->Type] ([Id])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__SubjectD__5DC631623FAE10DE] ON [Seminar].[SubjectDemand] ([Demand_Id] ASC, [Subject_Id] ASC);
GO
