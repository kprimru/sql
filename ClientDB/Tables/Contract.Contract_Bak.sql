USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[Contract_Bak]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [NUM]           Int                       NULL,
        [NUM_S]         NVarChar(256)         NOT NULL,
        [ID_TYPE]       UniqueIdentifier      NOT NULL,
        [ID_VENDOR]     UniqueIdentifier      NOT NULL,
        [REG_DATE]      SmallDateTime         NOT NULL,
        [DATE]          SmallDateTime             NULL,
        [NOTE]          NVarChar(Max)         NOT NULL,
        [ID_YEAR]       UniqueIdentifier      NOT NULL,
        [ID_CLIENT]     Int                       NULL,
        [CLIENT]        NVarChar(1024)            NULL,
        [RETURN_DATE]   SmallDateTime             NULL,
        [ID_STATUS]     UniqueIdentifier      NOT NULL,
        [STATUS]        SmallInt              NOT NULL,
        [UPD_DATE]      DateTime              NOT NULL,
        [UPD_USER]      NVarChar(256)         NOT NULL,
        [LAW]           NVarChar(Max)             NULL,
        [DateFrom]      SmallDateTime             NULL,
        [DateTo]        SmallDateTime             NULL,
        [SignDate]      SmallDateTime             NULL,
);
GO
