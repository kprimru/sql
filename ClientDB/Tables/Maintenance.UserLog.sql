USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Maintenance].[UserLog]
(
        [ID]         UniqueIdentifier      NOT NULL,
        [USR]        NVarChar(256)         NOT NULL,
        [COMP]       NVarChar(256)         NOT NULL,
        [OPER]       NVarChar(256)         NOT NULL,
        [DT]         DateTime              NOT NULL,
        [A1]         NVarChar(64)              NULL,
        [A2]         NVarChar(64)              NULL,
        [DT_SHORT]    AS ([dbo].[DateOf]([DT])) PERSISTED,
        CONSTRAINT [PK_Maintenance.UserLog] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Maintenance.UserLog(DT_SHORT)+(ID,USR,COMP,OPER,DT)] ON [Maintenance].[UserLog] ([DT_SHORT] ASC) INCLUDE ([ID], [USR], [COMP], [OPER], [DT]);
GO
