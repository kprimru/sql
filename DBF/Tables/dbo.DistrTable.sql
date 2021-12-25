﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrTable]
(
        [DIS_ID]          Int        Identity(1,1)   NOT NULL,
        [DIS_ID_SYSTEM]   SmallInt                   NOT NULL,
        [DIS_NUM]         Int                        NOT NULL,
        [DIS_COMP_NUM]    TinyInt                    NOT NULL,
        [DIS_ACTIVE]      Bit                        NOT NULL,
        [DIS_DELIVERY]    Bit                        NOT NULL,
        CONSTRAINT [PK_dbo.DistrTable] PRIMARY KEY CLUSTERED ([DIS_ID]),
        CONSTRAINT [FK_dbo.DistrTable(DIS_ID_SYSTEM)_dbo.SystemTable(SYS_ID)] FOREIGN KEY  ([DIS_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.DistrTable(DIS_ACTIVE)+(DIS_ID,DIS_ID_SYSTEM,DIS_NUM,DIS_COMP_NUM)] ON [dbo].[DistrTable] ([DIS_ACTIVE] ASC) INCLUDE ([DIS_ID], [DIS_ID_SYSTEM], [DIS_NUM], [DIS_COMP_NUM]);
CREATE NONCLUSTERED INDEX [IX_dbo.DistrTable(DIS_ID)+(DIS_ID_SYSTEM,DIS_NUM,DIS_COMP_NUM,DIS_ACTIVE)] ON [dbo].[DistrTable] ([DIS_ID] ASC) INCLUDE ([DIS_ID_SYSTEM], [DIS_NUM], [DIS_COMP_NUM], [DIS_ACTIVE]);
CREATE NONCLUSTERED INDEX [IX_dbo.DistrTable(DIS_ID_SYSTEM)+(DIS_ID,DIS_NUM,DIS_COMP_NUM)] ON [dbo].[DistrTable] ([DIS_ID_SYSTEM] ASC) INCLUDE ([DIS_ID], [DIS_NUM], [DIS_COMP_NUM]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.DistrTable(DIS_NUM,DIS_ID_SYSTEM,DIS_COMP_NUM)+(DIS_ID,DIS_ACTIVE)] ON [dbo].[DistrTable] ([DIS_NUM] ASC, [DIS_ID_SYSTEM] ASC, [DIS_COMP_NUM] ASC) INCLUDE ([DIS_ID], [DIS_ACTIVE]);
GO
