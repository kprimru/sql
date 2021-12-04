USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TODistrTable]
(
        [TD_ID]         Int   Identity(1,1)   NOT NULL,
        [TD_ID_DISTR]   Int                   NOT NULL,
        [TD_ID_TO]      Int                   NOT NULL,
        [TD_FORCED]     Bit                   NOT NULL,
        CONSTRAINT [PK_dbo.TODistrTable] PRIMARY KEY NONCLUSTERED ([TD_ID]),
        CONSTRAINT [FK_dbo.TODistrTable(TD_ID_TO)_dbo.TOTable(TO_ID)] FOREIGN KEY  ([TD_ID_TO]) REFERENCES [dbo].[TOTable] ([TO_ID]),
        CONSTRAINT [FK_dbo.TODistrTable(TD_ID_DISTR)_dbo.DistrTable(DIS_ID)] FOREIGN KEY  ([TD_ID_DISTR]) REFERENCES [dbo].[DistrTable] ([DIS_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.TODistrTable(TD_ID_TO,TD_ID_DISTR)] ON [dbo].[TODistrTable] ([TD_ID_TO] ASC, [TD_ID_DISTR] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.TODistrTable(TD_FORCED)+(TD_ID_DISTR,TD_ID_TO)] ON [dbo].[TODistrTable] ([TD_FORCED] ASC) INCLUDE ([TD_ID_DISTR], [TD_ID_TO]);
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.TODistrTable()] ON [dbo].[TODistrTable] ([TD_ID_DISTR] ASC);
GO
