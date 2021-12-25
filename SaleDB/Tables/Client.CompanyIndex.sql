USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyIndex]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_COMPANY]    UniqueIdentifier      NOT NULL,
        [DATA]          NVarChar(Max)             NULL,
        [ADDRESS]       NVarChar(1024)            NULL,
        [EMAILS]        NVarChar(Max)             NULL,
        [PROJECTS]      NVarChar(Max)             NULL,
        [AVA_COLOR]     Int                       NULL,
        [SenderIndex]   SmallInt                  NULL,
        CONSTRAINT [PK_Client.CompanyIndex] PRIMARY KEY NONCLUSTERED ([ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Client.CompanyIndex(ID_COMPANY)] ON [Client].[CompanyIndex] ([ID_COMPANY] ASC);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyIndex(ID_COMPANY)+(ADDRESS,EMAILS,PROJECTS)] ON [Client].[CompanyIndex] ([ID_COMPANY] ASC) INCLUDE ([ADDRESS], [EMAILS], [PROJECTS]);
GO
