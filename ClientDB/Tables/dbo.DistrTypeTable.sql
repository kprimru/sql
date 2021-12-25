USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrTypeTable]
(
        [DistrTypeID]          Int             Identity(1,1)   NOT NULL,
        [DistrTypeName]        VarChar(50)                     NOT NULL,
        [DistrTypeOrder]       Int                             NOT NULL,
        [DistrTypeFull]        NVarChar(100)                       NULL,
        [DistrTypeBaseCheck]   Bit                                 NULL,
        [DistrTypeCode]        VarChar(100)                        NULL,
        CONSTRAINT [PK_dbo.DistrTypeTable] PRIMARY KEY CLUSTERED ([DistrTypeID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.DistrTypeTable()] ON [dbo].[DistrTypeTable] ([DistrTypeName] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.DistrTypeTable(DistrTypeCode)] ON [dbo].[DistrTypeTable] ([DistrTypeCode] ASC);
GO
GRANT SELECT ON [dbo].[DistrTypeTable] TO BL_READER;
GRANT SELECT ON [dbo].[DistrTypeTable] TO claim_view;
GO
