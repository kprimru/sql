USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientAudit]
(
        [CA_ID]                Int             Identity(1,1)   NOT NULL,
        [CA_ID_CLIENT]         Int                             NOT NULL,
        [CA_DATE]              SmallDateTime                   NOT NULL,
        [CA_STUDY]             Bit                             NOT NULL,
        [CA_STUDY_DATE]        SmallDateTime                       NULL,
        [CA_SEARCH]            Bit                             NOT NULL,
        [CA_SEARCH_NOTE]       VarChar(Max)                        NULL,
        [CA_DUTY]              Bit                             NOT NULL,
        [CA_DUTY_DATE]         SmallDateTime                       NULL,
        [CA_DUTY_AVG]          decimal                             NULL,
        [CA_TRANSFER]          Bit                             NOT NULL,
        [CA_TRANSFER_NOTE]     VarChar(Max)                        NULL,
        [CA_RIVAL]             Bit                             NOT NULL,
        [CA_RIVAL_DATE]        SmallDateTime                       NULL,
        [CA_RIVAL_NOTE]        VarChar(Max)                        NULL,
        [CA_SYSTEM]            Bit                             NOT NULL,
        [CA_SYSTEM_COUNT]      Int                                 NULL,
        [CA_SYSTEM_ER_COUNT]   Int                                 NULL,
        [CA_INCOME]            Bit                                 NULL,
        [CA_INCOME_NOTE]       VarChar(Max)                        NULL,
        [CA_NOTE]              VarChar(Max)                        NULL,
        [CA_CONTROL]           Bit                                 NULL,
        [CA_CREATE]            DateTime                        NOT NULL,
        [CA_USER]              NVarChar(256)                   NOT NULL,
        CONSTRAINT [PK_dbo.ClientAudit] PRIMARY KEY CLUSTERED ([CA_ID]),
        CONSTRAINT [FK_dbo.ClientAudit(CA_ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([CA_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
