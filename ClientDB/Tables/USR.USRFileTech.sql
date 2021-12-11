USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [USR].[USRFileTech]
(
        [UF_ID]                    Int                   NOT NULL,
        [UF_FORMAT]                TinyInt               NOT NULL,
        [UF_RIC]                   SmallInt              NOT NULL,
        [UF_ID_RES]                Int                   NOT NULL,
        [UF_ID_CONS]               Int                       NULL,
        [UF_ID_KDVERSION]          UniqueIdentifier          NULL,
        [UF_ID_PROC]               Int                       NULL,
        [UF_RAM]                   Int                       NULL,
        [UF_ID_OS]                 Int                       NULL,
        [UF_BOOT_NAME]             VarChar(50)               NULL,
        [UF_BOOT_FREE]             bigint                    NULL,
        [UF_CONS_FREE]             bigint                NOT NULL,
        [UF_OFFICE]                VarChar(100)              NULL,
        [UF_BROWSER]               VarChar(100)              NULL,
        [UF_MAIL]                  VarChar(100)              NULL,
        [UF_RIGHT]                 VarChar(50)               NULL,
        [UF_OD]                    SmallInt              NOT NULL,
        [UF_UD]                    SmallInt              NOT NULL,
        [UF_TS]                    SmallInt              NOT NULL,
        [UF_VM]                    SmallInt                  NULL,
        [UF_INFO_COD]              DateTime                  NULL,
        [UF_INFO_CFG]              DateTime                  NULL,
        [UF_CONSULT_TOR]           DateTime                  NULL,
        [UF_FILE_SYSTEM]           VarChar(20)               NULL,
        [UF_EXPCONS]               DateTime                  NULL,
        [UF_EXPCONS_KIND]          VarChar(20)               NULL,
        [UF_EXPUSERS]              DateTime                  NULL,
        [UF_HOTLINE]               DateTime                  NULL,
        [UF_HOTLINE_KIND]          VarChar(20)               NULL,
        [UF_HOTLINEUSERS]          DateTime                  NULL,
        [UF_WINE_EXISTS]           VarChar(20)               NULL,
        [UF_WINE_VERSION]          VarChar(50)               NULL,
        [UF_NOWIN_NAME]            VarChar(128)              NULL,
        [UF_NOWIN_EXTEND]          VarChar(128)              NULL,
        [UF_NOWIN_UNNAME]          VarChar(512)              NULL,
        [UF_COMPLECT_TYPE]         VarChar(64)               NULL,
        [UF_TEMP_DIR]              VarChar(256)              NULL,
        [UF_TEMP_FREE]             bigint                    NULL,
        [UF_USERLIST]              Bit                       NULL,
        [UF_USERLISTONLINE]        Bit                       NULL,
        [UF_USERLISTUSERSONLINE]   SmallInt                  NULL,
        CONSTRAINT [PK_USR.USRFileTech] PRIMARY KEY CLUSTERED ([UF_ID]),
        CONSTRAINT [FK_USR.USRFileTech(UF_ID_OS)_USR.Os(OS_ID)] FOREIGN KEY  ([UF_ID_OS]) REFERENCES [USR].[Os] ([OS_ID]),
        CONSTRAINT [FK_USR.USRFileTech(UF_ID_PROC)_USR.Processor(PRC_ID)] FOREIGN KEY  ([UF_ID_PROC]) REFERENCES [USR].[Processor] ([PRC_ID]),
        CONSTRAINT [FK_USR.USRFileTech(UF_ID_CONS)_USR.ConsExeVersionTable(ConsExeVersionID)] FOREIGN KEY  ([UF_ID_CONS]) REFERENCES [dbo].[ConsExeVersionTable] ([ConsExeVersionID]),
        CONSTRAINT [FK_USR.USRFileTech(UF_ID_RES)_USR.ResVersionTable(ResVersionID)] FOREIGN KEY  ([UF_ID_RES]) REFERENCES [dbo].[ResVersionTable] ([ResVersionID]),
        CONSTRAINT [FK_USR.USRFileTech(UF_ID_KDVERSION)_USR.KDVersion(ID)] FOREIGN KEY  ([UF_ID_KDVERSION]) REFERENCES [dbo].[KDVersion] ([ID]),
        CONSTRAINT [FK_USR.USRFileTech(UF_ID)_USR.USRFile(UF_ID)] FOREIGN KEY  ([UF_ID]) REFERENCES [USR].[USRFile] ([UF_ID])
);
GO
