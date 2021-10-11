USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempActSystemsTable]
(
        [ID]                    Int            Identity(1,1)   NOT NULL,
        [ActID]                 Int                            NOT NULL,
        [SystemID]              Int                            NOT NULL,
        [DistrTypeID]           Int                            NOT NULL,
        [PriceAbonement]        Int                            NOT NULL,
        [DiscountRate]          decimal                        NOT NULL,
        [FixedSum]              Money                          NOT NULL,
        [SystemPriceModeName]   VarChar(50)                    NOT NULL,
        [SystemSet]             Int                            NOT NULL,
        [DistrNumber]           VarChar(150)                       NULL,,
        CONSTRAINT [FK_dbo.TempActSystemsTable(SystemID)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([SystemID]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_dbo.TempActSystemsTable(DistrTypeID)_dbo.DistrTypeTable(DistrTypeID)] FOREIGN KEY  ([DistrTypeID]) REFERENCES [dbo].[DistrTypeTable] ([DistrTypeID])
);GO
GRANT DELETE ON [dbo].[TempActSystemsTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[TempActSystemsTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[TempActSystemsTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[TempActSystemsTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[TempActSystemsTable] TO DBCount;
GRANT INSERT ON [dbo].[TempActSystemsTable] TO DBCount;
GRANT SELECT ON [dbo].[TempActSystemsTable] TO DBCount;
GRANT UPDATE ON [dbo].[TempActSystemsTable] TO DBCount;
GO
