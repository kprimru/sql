USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrTypeTable]
(
        [DistrTypeID]            Int            Identity(1,1)   NOT NULL,
        [DistrTypeName]          VarChar(50)                    NOT NULL,
        [DistrTypeMainStr]       VarChar(50)                        NULL,
        [DistrTypeCoefficient]   decimal                        NOT NULL,
        [DistrTypeStr]           VarChar(150)                   NOT NULL,
        [DistrTypeNet]           VarChar(10)                    NOT NULL,
        [DistrTypePrint]         Int                            NOT NULL,
        [DistrTypePsedo]         VarChar(50)                        NULL,
        [DistrTypeRound]         SmallInt                           NULL,
        [GenerateRow]            Bit                                NULL,
        CONSTRAINT [PK_dbo.DistrTypeTable] PRIMARY KEY CLUSTERED ([DistrTypeID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.DistrTypeTable(DistrTypeName)] ON [dbo].[DistrTypeTable] ([DistrTypeName] ASC);
GO
GRANT DELETE ON [dbo].[DistrTypeTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[DistrTypeTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[DistrTypeTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[DistrTypeTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[DistrTypeTable] TO DBCount;
GRANT INSERT ON [dbo].[DistrTypeTable] TO DBCount;
GRANT SELECT ON [dbo].[DistrTypeTable] TO DBCount;
GRANT UPDATE ON [dbo].[DistrTypeTable] TO DBCount;
GRANT SELECT ON [dbo].[DistrTypeTable] TO DBPrice;
GRANT SELECT ON [dbo].[DistrTypeTable] TO DBPriceReader;
GO
