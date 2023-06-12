USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemBankRequired]
(
        [ID]              UniqueIdentifier      NOT NULL,
        [ID_SB]           Int                   NOT NULL,
        [ID_SYSTEM]       Int                       NULL,
        [ID_NOT_SYSTEM]   Int                       NULL,
        CONSTRAINT [PK_dbo.SystemBankRequired] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.SystemBankRequired(ID_SB)_dbo.SystemBankTable(ID)] FOREIGN KEY  ([ID_SB]) REFERENCES [dbo].[SystemBankTable] ([ID]),
        CONSTRAINT [FK_dbo.SystemBankRequired(ID_SYSTEM)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_dbo.SystemBankRequired(ID)_dbo.SystemBankRequired(ID)] FOREIGN KEY  ([ID]) REFERENCES [dbo].[SystemBankRequired] ([ID]),
        CONSTRAINT [FK_dbo.SystemBankRequired(ID_NOT_SYSTEM)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([ID_NOT_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SystemID])
);
GO
