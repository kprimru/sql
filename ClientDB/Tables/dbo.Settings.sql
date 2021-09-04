USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Settings]
(
        [ST_ID]             Int              Identity(1,1)   NOT NULL,
        [ST_USER]           NVarChar(256)                        NULL,
        [ST_HOST]           NVarChar(256)                        NULL,
        [ST_CLIENT]         Bit                                  NULL,
        [ST_MENU]           Bit                                  NULL,
        [ST_EXT_SEARCH]     Bit                                  NULL,
        [ST_CA_STATUS]      Bit                                  NULL,
        [ST_CA_CATEGORY]    Bit                                  NULL,
        [ST_CA_INN]         Bit                                  NULL,
        [ST_CA_SERVICE]     Bit                                  NULL,
        [ST_CA_ACTIVITY]    Bit                                  NULL,
        [ST_CA_PAPPER]      Bit                                  NULL,
        [ST_CA_GRAPH]       Bit                                  NULL,
        [ST_EXP_NUM]        Bit                                  NULL,
        [ST_EXP_NAME]       Bit                                  NULL,
        [ST_EXP_ADDRESS]    Bit                                  NULL,
        [ST_EXP_INN]        Bit                                  NULL,
        [ST_EXP_DIR]        Bit                                  NULL,
        [ST_EXP_BUH]        Bit                                  NULL,
        [ST_EXP_RES]        Bit                                  NULL,
        [ST_EXP_TYPE]       Bit                                  NULL,
        [ST_EXP_PERSONAL]   Bit                                  NULL,
        [ST_EXP_BOOK]       Bit                                  NULL,
        [ST_EXP_PAPPER]     Bit                                  NULL,
        [ST_EXP_STATUS]     Bit                                  NULL,
        [ST_EXP_SYSTEM]     Bit                                  NULL,
        [ST_REP_SAVE]       Bit                                  NULL,
        [ST_REP_TYPE]       TinyInt                              NULL,
        [ST_REP_PATH]       NVarChar(1024)                       NULL,
        [ST_OFFER_PATH]     NVarChar(1024)                       NULL,
        [ST_SR_VISIBLE]     Bit                                  NULL,
        [ST_SR_COUNT]       SmallInt                             NULL,
        [ST_SR_SAVE]        Bit                                  NULL,
        [ST_DEBUG]          Bit                              NOT NULL,
        [ST_DATE]           DateTime                         NOT NULL,
        CONSTRAINT [PK_dbo.Settings] PRIMARY KEY NONCLUSTERED ([ST_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.Settings(ST_USER,ST_HOST)] ON [dbo].[Settings] ([ST_USER] ASC, [ST_HOST] ASC);
GO
