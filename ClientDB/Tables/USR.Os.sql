USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [USR].[Os]
(
        [OS_ID]              Int            Identity(1,1)   NOT NULL,
        [OS_NAME]            VarChar(100)                   NOT NULL,
        [OS_MIN]             SmallInt                       NOT NULL,
        [OS_MAJ]             SmallInt                       NOT NULL,
        [OS_BUILD]           SmallInt                       NOT NULL,
        [OS_PLATFORM]        TinyInt                        NOT NULL,
        [OS_EDITION]         VarChar(100)                       NULL,
        [OS_CAPACITY]        VarChar(50)                        NULL,
        [OS_LANG]            VarChar(50)                        NULL,
        [OS_COMPATIBILITY]   VarChar(100)                       NULL,
        [OS_ID_FAMILY]       Int                                NULL,
        CONSTRAINT [PK_USR.Os] PRIMARY KEY CLUSTERED ([OS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_USR.Os(OS_NAME)+INCL] ON [USR].[Os] ([OS_NAME] ASC) INCLUDE ([OS_ID], [OS_MIN], [OS_MAJ], [OS_BUILD], [OS_PLATFORM], [OS_EDITION], [OS_CAPACITY], [OS_LANG], [OS_COMPATIBILITY]);
GO
