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
        CONSTRAINT [PK_Seminar.SubjectDemand] PRIMARY KEY CLUSTERED ([Subject_Id],[Demand_Id]),
        CONSTRAINT [FK_Seminar.SubjectDemand(Subject_Id)_Seminar.Subject(ID)] FOREIGN KEY  ([Subject_Id]) REFERENCES [Seminar].[Subject] ([ID]),
        CONSTRAINT [FK_Seminar.SubjectDemand(Demand_Id)_dbo.Demand->Type(Id)] FOREIGN KEY  ([Demand_Id]) REFERENCES [dbo].[Demand->Type] ([Id])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Seminar.SubjectDemand(Demand_Id,Subject_Id)] ON [Seminar].[SubjectDemand] ([Demand_Id] ASC, [Subject_Id] ASC);
GO
