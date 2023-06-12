USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrDocumentTable]
(
        [DD_ID]         Int        Identity(1,1)   NOT NULL,
        [DD_ID_DISTR]   Int                        NOT NULL,
        [DD_ID_DOC]     SmallInt                   NOT NULL,
        [DD_PRINT]      Bit                        NOT NULL,
        [DD_ID_GOOD]    SmallInt                       NULL,
        [DD_ID_UNIT]    SmallInt                       NULL,
        [DD_PREFIX]     Bit                            NULL,
        CONSTRAINT [PK_dbo.DistrDocumentTable] PRIMARY KEY NONCLUSTERED ([DD_ID]),
        CONSTRAINT [FK_dbo.DistrDocumentTable(DD_ID_DOC)_dbo.DocumentTable(DOC_ID)] FOREIGN KEY  ([DD_ID_DOC]) REFERENCES [dbo].[DocumentTable] ([DOC_ID]),
        CONSTRAINT [FK_dbo.DistrDocumentTable(DD_ID_UNIT)_dbo.UnitTable(UN_ID)] FOREIGN KEY  ([DD_ID_UNIT]) REFERENCES [dbo].[UnitTable] ([UN_ID]),
        CONSTRAINT [FK_dbo.DistrDocumentTable(DD_ID_GOOD)_dbo.GoodTable(GD_ID)] FOREIGN KEY  ([DD_ID_GOOD]) REFERENCES [dbo].[GoodTable] ([GD_ID]),
        CONSTRAINT [FK_dbo.DistrDocumentTable(DD_ID_DISTR)_dbo.DistrTable(DIS_ID)] FOREIGN KEY  ([DD_ID_DISTR]) REFERENCES [dbo].[DistrTable] ([DIS_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.DistrDocumentTable(DD_ID_DISTR,DD_ID_DOC,DD_PRINT)] ON [dbo].[DistrDocumentTable] ([DD_ID_DISTR] ASC, [DD_ID_DOC] ASC, [DD_PRINT] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.DistrDocumentTable(DD_ID_DOC,DD_PRINT)+(DD_ID_DISTR,DD_ID_GOOD,DD_ID_UNIT)] ON [dbo].[DistrDocumentTable] ([DD_ID_DOC] ASC, [DD_PRINT] ASC) INCLUDE ([DD_ID_DISTR], [DD_ID_GOOD], [DD_ID_UNIT]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.DistrDocumentTable(DD_ID_DISTR,DD_ID_DOC)] ON [dbo].[DistrDocumentTable] ([DD_ID_DISTR] ASC, [DD_ID_DOC] ASC);
GO
