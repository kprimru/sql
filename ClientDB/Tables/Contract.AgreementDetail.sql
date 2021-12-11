USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[AgreementDetail]
(
        [ID]                 UniqueIdentifier      NOT NULL,
        [ID_SPECIFICATION]   UniqueIdentifier          NULL,
        [ID_ADDITIONAL]      UniqueIdentifier          NULL,
        [NOTE]               NVarChar(Max)         NOT NULL,
        [ID_STATUS]          UniqueIdentifier      NOT NULL,
        [UPD_DATE]           DateTime              NOT NULL,
        [UPD_USER]           NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Contract.AgreementDetail] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Contract.AgreementDetail(ID_SPECIFICATION)_Contract.ContractSpecification(ID)] FOREIGN KEY  ([ID_SPECIFICATION]) REFERENCES [Contract].[ContractSpecification] ([ID]),
        CONSTRAINT [FK_Contract.AgreementDetail(ID_ADDITIONAL)_Contract.Additional(ID)] FOREIGN KEY  ([ID_ADDITIONAL]) REFERENCES [Contract].[Additional] ([ID]),
        CONSTRAINT [FK_Contract.AgreementDetail(ID_STATUS)_Contract.Status(ID)] FOREIGN KEY  ([ID_STATUS]) REFERENCES [Contract].[Status] ([ID])
);
GO
