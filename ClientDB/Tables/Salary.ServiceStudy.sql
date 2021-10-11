USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salary].[ServiceStudy]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_SALARY]   UniqueIdentifier      NOT NULL,
        [ID_CLIENT]   Int                   NOT NULL,
        [DATE]        SmallDateTime         NOT NULL,
        CONSTRAINT [PK_Salary.ServiceStudy] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Salary.ServiceStudy(ID_SALARY)_Salary.Service(ID)] FOREIGN KEY  ([ID_SALARY]) REFERENCES [Salary].[Service] ([ID]),
        CONSTRAINT [FK_Salary.ServiceStudy(ID_CLIENT)_Salary.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Salary.ServiceStudy(ID_SALARY)+(ID_CLIENT,DATE)] ON [Salary].[ServiceStudy] ([ID_SALARY] ASC) INCLUDE ([ID_CLIENT], [DATE]);
GO
