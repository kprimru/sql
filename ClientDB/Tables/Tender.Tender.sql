USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tender].[Tender]
(
        [ID]                UniqueIdentifier      NOT NULL,
        [ID_MASTER]         UniqueIdentifier          NULL,
        [ID_CLIENT]         Int                   NOT NULL,
        [ID_LAW]            UniqueIdentifier          NULL,
        [CLIENT]            NVarChar(512)         NOT NULL,
        [CONTRACT_START]    SmallDateTime             NULL,
        [CONTRACT_FINISH]   SmallDateTime             NULL,
        [ACT_START]         SmallDateTime             NULL,
        [ACT_FINISH]        SmallDateTime             NULL,
        [TENDER_START]      SmallDateTime             NULL,
        [TENDER_FINISH]     SmallDateTime             NULL,
        [SURNAME]           NVarChar(256)             NULL,
        [NAME]              NVarChar(256)             NULL,
        [PATRON]            NVarChar(256)             NULL,
        [POSITION]          NVarChar(512)             NULL,
        [PHONE]             NVarChar(256)             NULL,
        [EMAIL]             NVarChar(512)             NULL,
        [ID_STATUS]         UniqueIdentifier      NOT NULL,
        [CALL_DATE]         SmallDateTime             NULL,
        [INFO_DATE]         SmallDateTime         NOT NULL,
        [MANAGER]           Bit                       NULL,
        [MANAGER_DATE]      SmallDateTime             NULL,
        [ID_MANAGER]        Int                       NULL,
        [STATUS]            TinyInt               NOT NULL,
        [UPD_DATE]          DateTime              NOT NULL,
        [UPD_USER]          NVarChar(256)         NOT NULL,
        [MANAGER_NOTE]      NVarChar(1024)            NULL,
        [LET_NUM]           NVarChar(128)             NULL,
        [LET_DATE]          SmallDateTime             NULL,
        CONSTRAINT [PK_Tender.Tender] PRIMARY KEY CLUSTERED ([ID])
);GO
