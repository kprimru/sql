USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salary].[Service]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [ID_MONTH]       UniqueIdentifier      NOT NULL,
        [ID_SERVICE]     Int                   NOT NULL,
        [ID_POSITION]    Int                   NOT NULL,
        [MANAGER_RATE]   Int                   NOT NULL,
        [INSURANCE]      Int                       NULL,
        CONSTRAINT [PK_Salary.Service] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Salary.Service(ID_MONTH)_Salary.Period(ID)] FOREIGN KEY  ([ID_MONTH]) REFERENCES [Common].[Period] ([ID]),
        CONSTRAINT [FK_Salary.Service(ID_SERVICE)_Salary.ServiceTable(ServiceID)] FOREIGN KEY  ([ID_SERVICE]) REFERENCES [dbo].[ServiceTable] ([ServiceID]),
        CONSTRAINT [FK_Salary.Service(ID_POSITION)_Salary.ServicePositionTable(ServicePositionID)] FOREIGN KEY  ([ID_POSITION]) REFERENCES [dbo].[ServicePositionTable] ([ServicePositionID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Salary.Service(ID_SERVICE,ID_MONTH)] ON [Salary].[Service] ([ID_SERVICE] ASC, [ID_MONTH] ASC);
GO
