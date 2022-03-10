USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[DistrIncome]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [ID_TYPE]        UniqueIdentifier      NOT NULL,
        [NUM]            Int                   NOT NULL,
        [COMP]           TinyInt               NOT NULL,
        [ID_SYSTEM]      UniqueIdentifier          NULL,
        [ID_OLD_SYS]     UniqueIdentifier          NULL,
        [ID_NEW_SYS]     UniqueIdentifier          NULL,
        [ID_NET]         UniqueIdentifier          NULL,
        [ID_OLD_NET]     UniqueIdentifier          NULL,
        [ID_NEW_NET]     UniqueIdentifier          NULL,
        [INCOME_DATE]    DateTime                  NULL,
        [COMMENT]        NVarChar(300)             NULL,
        [ID_SUBHOST]     UniqueIdentifier          NULL,
        [PROCESS_DATE]   DateTime                  NULL,
        [UPD_DATE]       DateTime                  NULL,
        CONSTRAINT [PK_Distr.DistrIncome] PRIMARY KEY CLUSTERED ([ID])
);GO
