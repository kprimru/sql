USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemBankTable]
(
        [ID]           Int        Identity(1,1)   NOT NULL,
        [InfoBankID]   SmallInt                   NOT NULL,
        [SystemID]     SmallInt                   NOT NULL,
        [Required]     TinyInt                    NOT NULL,
        CONSTRAINT [PK_dbo.SystemBankTable] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.SystemBankTable(InfoBankID)_dbo.InfoBankTable(InfoBankID)] FOREIGN KEY  ([InfoBankID]) REFERENCES [dbo].[InfoBankTable] ([InfoBankID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.SystemBankTable(SystemID,InfoBankID)] ON [dbo].[SystemBankTable] ([SystemID] ASC, [InfoBankID] ASC);
GO
GRANT SELECT ON [dbo].[SystemBankTable] TO claim_view;
GRANT SELECT ON [dbo].[SystemBankTable] TO COMPLECTBASE;
GO
