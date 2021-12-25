USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrDocumentTable_Bak]
(
        [DD_ID]         Int        Identity(1,1)   NOT NULL,
        [DD_ID_DISTR]   Int                        NOT NULL,
        [DD_ID_DOC]     SmallInt                   NOT NULL,
        [DD_PRINT]      Bit                        NOT NULL,
        [DD_ID_GOOD]    SmallInt                       NULL,
        [DD_ID_UNIT]    SmallInt                       NULL,
        [DD_PREFIX]     Bit                            NULL,
);GO
