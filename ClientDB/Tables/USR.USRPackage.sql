USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [USR].[USRPackage]
(
        [UP_ID_USR]      Int              NOT NULL,
        [UP_ID_SYSTEM]   SmallInt         NOT NULL,
        [UP_DISTR]       Int              NOT NULL,
        [UP_COMP]        TinyInt          NOT NULL,
        [UP_RIC]         SmallInt         NOT NULL,
        [UP_NET]         SmallInt         NOT NULL,
        [UP_TECH]        VarChar(20)      NOT NULL,
        [UP_TYPE]        VarChar(20)      NOT NULL,
        [UP_FORMAT]      SmallInt             NULL,
        CONSTRAINT [PK_USR.USRPackage] PRIMARY KEY CLUSTERED ([UP_ID_USR],[UP_ID_SYSTEM]),
        CONSTRAINT [FK_USR.USRPackage(UP_ID_USR)_USR.USRFile(UF_ID)] FOREIGN KEY  ([UP_ID_USR]) REFERENCES [USR].[USRFile] ([UF_ID])
);GO
