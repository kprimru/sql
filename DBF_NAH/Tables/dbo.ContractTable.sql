USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractTable]
(
        [CO_ID]          Int             Identity(1,1)   NOT NULL,
        [CO_ID_CLIENT]   Int                             NOT NULL,
        [CO_NUM]         VarChar(500)                        NULL,
        [CO_ID_TYPE]     SmallInt                            NULL,
        [CO_DATE]        SmallDateTime                       NULL,
        [CO_BEG_DATE]    SmallDateTime                       NULL,
        [CO_END_DATE]    SmallDateTime                       NULL,
        [CO_ACTIVE]      Bit                             NOT NULL,
        [CO_ID_PAY]      SmallInt                            NULL,
        [CO_ID_KIND]     SmallInt                            NULL,
        [CO_IDENT]       NVarChar(256)                       NULL,
        [CO_KEY]         VarChar(256)                        NULL,
        [CO_NUM_FROM]    VarChar(256)                        NULL,
        [CO_NUM_TO]      VarChar(256)                        NULL,
        [CO_EMAIL]       VarChar(256)                        NULL,
        CONSTRAINT [PK_dbo.ContractTable] PRIMARY KEY NONCLUSTERED ([CO_ID]),
        CONSTRAINT [FK_dbo.ContractTable(CO_ID_PAY)_dbo.ContractPayTable(COP_ID)] FOREIGN KEY  ([CO_ID_PAY]) REFERENCES [dbo].[ContractPayTable] ([COP_ID]),
        CONSTRAINT [FK_dbo.ContractTable(CO_ID_TYPE)_dbo.ContractTypeTable(CTT_ID)] FOREIGN KEY  ([CO_ID_TYPE]) REFERENCES [dbo].[ContractTypeTable] ([CTT_ID]),
        CONSTRAINT [FK_dbo.ContractTable(CO_ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([CO_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID]),
        CONSTRAINT [FK_dbo.ContractTable(CO_ID_KIND)_dbo.ContractKind(CK_ID)] FOREIGN KEY  ([CO_ID_KIND]) REFERENCES [dbo].[ContractKind] ([CK_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ContractTable(CO_ID_CLIENT,CO_ID_TYPE,CO_ID,CO_NUM,CO_DATE,CO_ACTIVE)] ON [dbo].[ContractTable] ([CO_ID_CLIENT] ASC, [CO_ID_TYPE] ASC, [CO_ID] ASC, [CO_NUM] ASC, [CO_DATE] ASC, [CO_ACTIVE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ContractTable(CO_BEG_DATE,CO_END_DATE)] ON [dbo].[ContractTable] ([CO_BEG_DATE] ASC, [CO_END_DATE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ContractTable(CO_NUM)+(CO_ID_CLIENT)] ON [dbo].[ContractTable] ([CO_NUM] ASC) INCLUDE ([CO_ID_CLIENT]);
GO
GRANT SELECT ON [dbo].[ContractTable] TO rl_all_r;
GRANT SELECT ON [dbo].[ContractTable] TO rl_client_fin_r;
GRANT SELECT ON [dbo].[ContractTable] TO rl_client_r;
GRANT SELECT ON [dbo].[ContractTable] TO rl_fin_r;
GRANT SELECT ON [dbo].[ContractTable] TO rl_to_r;
GO
