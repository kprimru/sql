USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InfoBankTable]
(
        [InfoBankID]          SmallInt        Identity(1,1)   NOT NULL,
        [InfoBankName]        VarChar(20)                     NOT NULL,
        [InfoBankShortName]   NVarChar(100)                   NOT NULL,
        [InfoBankFullName]    VarChar(250)                        NULL,
        [InfoBankOrder]       Int                                 NULL,
        [InfoBankPath]        VarChar(255)                        NULL,
        [InfoBankActive]      Bit                                 NULL,
        [InfoBankDaily]       Bit                                 NULL,
        [InfoBankActual]      Bit                                 NULL,
        [InfoBankStart]       SmallDateTime                       NULL,
        [InfoBankRegion]      Bit                                 NULL,
        CONSTRAINT [PK_dbo.InfoBankTable] PRIMARY KEY CLUSTERED ([InfoBankID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.InfoBankTable(InfoBankName)] ON [dbo].[InfoBankTable] ([InfoBankName] ASC);
GO
GRANT SELECT ON [dbo].[InfoBankTable] TO claim_view;
GRANT SELECT ON [dbo].[InfoBankTable] TO COMPLECTBASE;
GO
