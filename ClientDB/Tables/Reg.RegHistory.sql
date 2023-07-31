USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reg].[RegHistory]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_DISTR]     UniqueIdentifier      NOT NULL,
        [DATE]         SmallDateTime         NOT NULL,
        [ID_SYSTEM]    Int                   NOT NULL,
        [ID_NET]       Int                   NOT NULL,
        [ID_TYPE]      Int                   NOT NULL,
        [SUBHOST]      TinyInt               NOT NULL,
        [TRAN_COUNT]   SmallInt              NOT NULL,
        [TRAN_LEFT]    SmallInt              NOT NULL,
        [ID_STATUS]    UniqueIdentifier      NOT NULL,
        [REG_DATE]     SmallDateTime             NULL,
        [FIRST_REG]    SmallDateTime             NULL,
        [COMPLECT]     VarChar(50)               NULL,
        [COMMENT]      VarChar(150)              NULL,
        [OFFLINE]      VarChar(50)               NULL,
        CONSTRAINT [PK_Reg.RegHistory] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_Reg.RegHistory(ID_TYPE)_Din.SystemType(SST_ID)] FOREIGN KEY  ([ID_TYPE]) REFERENCES [Din].[SystemType] ([SST_ID]),
        CONSTRAINT [FK_Reg.RegHistory(ID_SYSTEM)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_Reg.RegHistory(ID_STATUS)_dbo.DistrStatus(DS_ID)] FOREIGN KEY  ([ID_STATUS]) REFERENCES [dbo].[DistrStatus] ([DS_ID]),
        CONSTRAINT [FK_Reg.RegHistory(ID_DISTR)_Reg.RegDistr(ID)] FOREIGN KEY  ([ID_DISTR]) REFERENCES [Reg].[RegDistr] ([ID]),
        CONSTRAINT [FK_Reg.RegHistory(ID_NET)_Din.NetType(NT_ID)] FOREIGN KEY  ([ID_NET]) REFERENCES [Din].[NetType] ([NT_ID])
);
GO
CREATE CLUSTERED INDEX [IC_Reg.RegHistory(ID_DISTR)] ON [Reg].[RegHistory] ([ID_DISTR] ASC);
CREATE NONCLUSTERED INDEX [IX_Reg.RegHistory(COMPLECT)] ON [Reg].[RegHistory] ([COMPLECT] ASC);
CREATE NONCLUSTERED INDEX [IX_Reg.RegHistory(ID_STATUS,COMPLECT)+(ID_DISTR,DATE,ID_SYSTEM,ID_NET,ID_TYPE)] ON [Reg].[RegHistory] ([ID_STATUS] ASC, [COMPLECT] ASC) INCLUDE ([ID_DISTR], [DATE], [ID_SYSTEM], [ID_NET], [ID_TYPE]);
CREATE NONCLUSTERED INDEX [IX_Reg.RegHistory(ID_SYSTEM)+(ID,ID_DISTR,DATE,ID_NET,ID_TYPE,SUBHOST,TRAN_COUNT,TRAN_LEFT,ID_STATUS,REG_DATE,FIRST_REG,COMPLECT] ON [Reg].[RegHistory] ([ID_SYSTEM] ASC) INCLUDE ([ID], [ID_DISTR], [DATE], [ID_NET], [ID_TYPE], [SUBHOST], [TRAN_COUNT], [TRAN_LEFT], [ID_STATUS], [REG_DATE], [FIRST_REG], [COMPLECT], [COMMENT]);
GO
