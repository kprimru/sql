USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Meta].[Reference]
(
        [REF_ID]             UniqueIdentifier      NOT NULL,
        [REF_NAME]           VarChar(50)           NOT NULL,
        [REF_TITLE]          VarChar(100)          NOT NULL,
        [REF_SCHEMA]         VarChar(50)           NOT NULL,
        [REF_TABLE]          VarChar(50)               NULL,
        [REF_VIEW]           VarChar(50)               NULL,
        [REF_KEY]            VarChar(20)           NOT NULL,
        [REF_VAL]            VarChar(20)           NOT NULL,
        [REF_ID_MASTER]      UniqueIdentifier          NULL,
        [REF_MASTER_KEY]     VarChar(20)               NULL,
        [REF_LOG]            Bit                   NOT NULL,
        [REF_REF]            Bit                   NOT NULL,
        [REF_INSERT_SQL]     VarChar(250)              NULL,
        [REF_UPDATE_SQL]     VarChar(250)              NULL,
        [REF_CHRONO_SQL]     VarChar(250)              NULL,
        [REF_DELETE_SQL]     VarChar(250)              NULL,
        [REF_SELECT_SQL]     VarChar(250)              NULL,
        [REF_DELETED_SQL]    VarChar(250)              NULL,
        [REF_DEFAULT_SORT]   VarChar(100)              NULL,
        CONSTRAINT [PK_Reference] PRIMARY KEY CLUSTERED ([REF_ID]),
        CONSTRAINT [FK_Reference_Reference] FOREIGN KEY  ([REF_ID_MASTER]) REFERENCES [Meta].[Reference] ([REF_ID])
);GO
