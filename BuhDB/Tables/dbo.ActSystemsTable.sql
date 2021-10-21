USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActSystemsTable]
(
        [ActID]           Int                            NOT NULL,
        [SystemID]        Int            Identity(1,1)   NOT NULL,
        [SystemPrefix]    VarChar(100)                       NULL,
        [SystemName]      VarChar(250)                   NOT NULL,
        [DocCount]        VarChar(10)                    NOT NULL,
        [SystemSet]       Int                            NOT NULL,
        [DistrTypeName]   VarChar(150)                   NOT NULL,
        [DistrNumber]     VarChar(100)                   NOT NULL,
        [NetVersion]      VarChar(50)                    NOT NULL,
        [SystemNote]      VarChar(250)                   NOT NULL,
        [SystemPrice]     Money                          NOT NULL,
        [TaxPrice]        Money                          NOT NULL,
        [SystemOrder]     Int                            NOT NULL,
        [SystemExpire]    VarChar(20)                        NULL,
        [IsGenerated]     Bit                                NULL,,
        CONSTRAINT [FK_dbo.ActSystemsTable(ActID)_dbo.ActTable(ActID)] FOREIGN KEY  ([ActID]) REFERENCES [dbo].[ActTable] ([ActID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ActSystemsTable(ActID)] ON [dbo].[ActSystemsTable] ([ActID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ActSystemsTable(DistrNumber)+(ActID)] ON [dbo].[ActSystemsTable] ([DistrNumber] ASC) INCLUDE ([ActID]);
GO
GRANT DELETE ON [dbo].[ActSystemsTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[ActSystemsTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[ActSystemsTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[ActSystemsTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[ActSystemsTable] TO DBCount;
GRANT INSERT ON [dbo].[ActSystemsTable] TO DBCount;
GRANT SELECT ON [dbo].[ActSystemsTable] TO DBCount;
GRANT UPDATE ON [dbo].[ActSystemsTable] TO DBCount;
GO
