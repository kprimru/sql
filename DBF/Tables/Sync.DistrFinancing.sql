USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sync].[DistrFinancing]
(
        [SYS_REG_NAME]   VarChar(50)      NOT NULL,
        [DIS_NUM]        Int              NOT NULL,
        [DIS_COMP_NUM]   TinyInt          NOT NULL,
        [UPD_DATE]       DateTime         NOT NULL,
        CONSTRAINT [PK_DistrFinancing] PRIMARY KEY CLUSTERED ([SYS_REG_NAME],[DIS_NUM],[DIS_COMP_NUM])
);GO
