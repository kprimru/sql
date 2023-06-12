USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salary].[ServiceClient]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_SALARY]   UniqueIdentifier      NOT NULL,
        [ID_CLIENT]   Int                   NOT NULL,
        CONSTRAINT [PK_Salary.ServiceClient] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Salary.ServiceClient(ID_SALARY)_Salary.Service(ID)] FOREIGN KEY  ([ID_SALARY]) REFERENCES [Salary].[Service] ([ID]),
        CONSTRAINT [FK_Salary.ServiceClient(ID_CLIENT)_Salary.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Salary.ServiceClient(ID_SALARY)+(ID_CLIENT)] ON [Salary].[ServiceClient] ([ID_SALARY] ASC) INCLUDE ([ID_CLIENT]);
GO
