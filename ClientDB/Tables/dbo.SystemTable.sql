USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemTable]
(
        [SystemID]             Int             Identity(1,1)   NOT NULL,
        [SystemShortName]      VarChar(20)                     NOT NULL,
        [SystemName]           VarChar(200)                    NOT NULL,
        [SystemBaseName]       VarChar(50)                     NOT NULL,
        [SystemNumber]         Int                             NOT NULL,
        [HostID]               Int                                 NULL,
        [SystemRic]            Int                                 NULL,
        [MainInfoBankID]       Int                                 NULL,
        [SystemOrder]          Int                                 NULL,
        [SystemVMI]            Int                                 NULL,
        [SystemFullName]       VarChar(250)                        NULL,
        [SystemDin]            VarChar(250)                        NULL,
        [SystemActive]         Bit                                 NULL,
        [SystemStart]          SmallDateTime                       NULL,
        [SystemEnd]            SmallDateTime                       NULL,
        [SystemDemo]           Bit                                 NULL,
        [SystemComplect]       Bit                                 NULL,
        [SystemReg]            Bit                                 NULL,
        [SystemBaseCheck]      Bit                                 NULL,
        [SystemSalaryWeight]   decimal                             NULL,
        CONSTRAINT [PK_dbo.SystemTable] PRIMARY KEY CLUSTERED ([SystemID]),
        CONSTRAINT [FK_dbo.SystemTable(HostID)_dbo.Hosts(HostID)] FOREIGN KEY  ([HostID]) REFERENCES [dbo].[Hosts] ([HostID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.SystemTable(SystemBaseName,SystemNumber,SystemID)+(HostID)] ON [dbo].[SystemTable] ([SystemBaseName] ASC, [SystemNumber] ASC, [SystemID] ASC) INCLUDE ([HostID]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.SystemTable(SystemShortName)] ON [dbo].[SystemTable] ([SystemShortName] ASC);
GO
GRANT SELECT ON [dbo].[SystemTable] TO BL_ADMIN;
GRANT SELECT ON [dbo].[SystemTable] TO BL_EDITOR;
GRANT SELECT ON [dbo].[SystemTable] TO BL_PARAM;
GRANT SELECT ON [dbo].[SystemTable] TO BL_READER;
GRANT SELECT ON [dbo].[SystemTable] TO BL_RGT;
GRANT SELECT ON [dbo].[SystemTable] TO claim_view;
GRANT SELECT ON [dbo].[SystemTable] TO COMPLECTBASE;
GO
