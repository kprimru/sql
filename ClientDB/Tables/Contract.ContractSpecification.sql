USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[ContractSpecification]
(
        [ID]                 UniqueIdentifier      NOT NULL,
        [ID_CONTRACT]        UniqueIdentifier      NOT NULL,
        [ID_SPECIFICATION]   UniqueIdentifier      NOT NULL,
        [NUM]                Int                   NOT NULL,
        [REG_DATE]           SmallDateTime         NOT NULL,
        [DATE]               SmallDateTime             NULL,
        [START_DATE]         SmallDateTime             NULL,
        [FINISH_DATE]        SmallDateTime             NULL,
        [RETURN_DATE]        SmallDateTime             NULL,
        [ID_STATUS]          UniqueIdentifier      NOT NULL,
        [NOTE]               NVarChar(Max)         NOT NULL,
        [UPD_DATE]           DateTime              NOT NULL,
        [UPD_USER]           NVarChar(256)         NOT NULL,
        [DateFrom]           SmallDateTime             NULL,
        [DateTo]             SmallDateTime             NULL,
        [SignDate]           SmallDateTime             NULL,
        [Comment]            NVarChar(Max)             NULL,
        CONSTRAINT [PK_Contract.ContractSpecification] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Contract.ContractSpecification(ID_SPECIFICATION)_Contract.Specification(ID)] FOREIGN KEY  ([ID_SPECIFICATION]) REFERENCES [Contract].[Specification] ([ID]),
        CONSTRAINT [FK_Contract.ContractSpecification(ID_CONTRACT)_Contract.Contract(ID)] FOREIGN KEY  ([ID_CONTRACT]) REFERENCES [Contract].[Contract] ([ID]),
        CONSTRAINT [FK_Contract.ContractSpecification(ID_STATUS)_Contract.Status(ID)] FOREIGN KEY  ([ID_STATUS]) REFERENCES [Contract].[Status] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Contract.ContractSpecification(ID_CONTRACT,ID_SPECIFICATION)] ON [Contract].[ContractSpecification] ([ID_CONTRACT] ASC, [ID_SPECIFICATION] ASC);
GO
