USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractTable]
(
        [ContractID]           Int                Identity(1,1)   NOT NULL,
        [ContractNumber]       VarChar(200)                       NOT NULL,
        [ContractYear]         VarChar(10)                        NOT NULL,
        [ContractTypeID]       Int                                NOT NULL,
        [ClientID]             Int                                NOT NULL,
        [ContractDate]         SmallDateTime                          NULL,
        [ContractBegin]        SmallDateTime                          NULL,
        [ContractEnd]          SmallDateTime                          NULL,
        [ContractConditions]   VarChar(250)                           NULL,
        [ContractPayID]        Int                                    NULL,
        [DiscountID]           Int                                    NULL,
        [ID_FOUNDATION]        UniqueIdentifier                       NULL,
        [FOUND_END]            SmallDateTime                          NULL,
        [FOUND_NOTE]           NVarChar(Max)                          NULL,
        [ContractFixed]        Money                                  NULL,
        CONSTRAINT [PK_dbo.ContractTable] PRIMARY KEY NONCLUSTERED ([ContractID]),
        CONSTRAINT [FK_dbo.ContractTable(ContractPayID)_dbo.ContractPayTable(ContractPayID)] FOREIGN KEY  ([ContractPayID]) REFERENCES [dbo].[ContractPayTable] ([ContractPayID]),
        CONSTRAINT [FK_dbo.ContractTable(DiscountID)_dbo.DiscountTable(DiscountID)] FOREIGN KEY  ([DiscountID]) REFERENCES [dbo].[DiscountTable] ([DiscountID]),
        CONSTRAINT [FK_dbo.ContractTable(ClientID)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ClientID]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ContractTable(ID_FOUNDATION)_dbo.ContractFoundation(ID)] FOREIGN KEY  ([ID_FOUNDATION]) REFERENCES [dbo].[ContractFoundation] ([ID]),
        CONSTRAINT [FK_dbo.ContractTable(ContractTypeID)_dbo.ContractTypeTable(ContractTypeID)] FOREIGN KEY  ([ContractTypeID]) REFERENCES [dbo].[ContractTypeTable] ([ContractTypeID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ContractTable(ClientID,ContractID)] ON [dbo].[ContractTable] ([ClientID] ASC, [ContractID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ContractTable(ContractBegin,ContractEnd)+(ContractPayID)] ON [dbo].[ContractTable] ([ContractBegin] ASC, [ContractEnd] ASC) INCLUDE ([ContractPayID]);
CREATE NONCLUSTERED INDEX [IX_dbo.ContractTable(ContractEnd)+(ContractID,ClientID,ContractPayID)] ON [dbo].[ContractTable] ([ContractEnd] ASC) INCLUDE ([ContractID], [ClientID], [ContractPayID]);
GO
